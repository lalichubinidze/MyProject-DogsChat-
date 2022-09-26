
import UIKit
import Gallery
import ProgressHUD 

final class ProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var profileCellBackgroundView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameAgeLbl: UILabel!
    @IBOutlet weak var cityCountryLbl: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var lookingForTextField: UITextField!
    @IBOutlet weak var ageFromLbl: UILabel!
    @IBOutlet weak var ageToLbl: UILabel!
    @IBOutlet weak var ageFromSlider: UISlider!
    @IBOutlet weak var ageToSlider: UISlider!

    //MARK: - Vars
    var editingMode = false
    var uploadingAvatar = true
    var profileImage:  UIImage?
    var gallery: GalleryController!
    var alertTextField: UITextField!

    var genderPickerView: UIPickerView!
    var genderOptions = ["Male", "Female"]

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupPickerView()
        setupBackgrounds()
        setAgeLabels()

        if FUser.currentUser() != nil {
            loadUserData()
            updateEditingMode()
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    //MARK: - IBActions

    @IBAction func settingsBtn(_ sender: Any) {
        showEditOptions()
    }

    @IBAction func cameraBtn(_ sender: Any) {
        showPictureOptions()
    }
    
    @IBAction func editBtn(_ sender: Any) {
        editingMode.toggle()
        updateEditingMode()
        editingMode ? showKeyboard() : hideKeyboard()
        showSaveButton()
    }

    @objc func editUserData()  {
        let user = FUser.currentUser()!

        user.about = aboutMeTextView.text
        user.breed = breedTextField.text ?? ""
        user.weight = Double (weightTextField.text ?? "0") ?? 0.0
        user.height = Double (heightTextField.text ?? "0") ?? 0.0
        user.isMale = genderTextField.text == "Male"
        user.city = cityTextField.text ?? ""
        user.country = countryTextField.text ?? ""
        user.lookingFor  = lookingForTextField.text ?? ""

        if profileImage != nil {
            //upload new profile Image
            //save user
            uploadAvatar(profileImage!) { avatarLink in

                user.avatarLink = avatarLink ?? ""
                user.avatar = self.profileImage

                self.saveUserData(user: user)
                self.loadUserData()
            }

        } else {
            //save
            saveUserData(user: user)
            loadUserData()
        }

        editingMode = false
        updateEditingMode()
        showSaveButton()
    }

    private func saveUserData(user: FUser) {
        user.saveUserLocally()
        user.saveUserToFireStore()

    }

    @IBAction func ageFromValueChanged(_ sender: UISlider) {
        self.ageFromLbl.text = "Age from " + String(format: "%.0f", sender.value)
        saveAgeSettings()
    }

    @IBAction func ageToValueChanged(_ sender: UISlider) {
        self.ageToLbl.text = "Age to " + String(format: "%.0f", sender.value)
        saveAgeSettings()
    }
    private func saveAgeSettings() {

        userDefaults.setValue(ageFromSlider.value, forKey: kAGEFROM)
        userDefaults.setValue(ageToSlider.value, forKey: kAGETO)
        userDefaults.synchronize()
    }
    private func setAgeLabels() {

        let ageFrom = userDefaults.object(forKey: kAGEFROM) as? Float ?? 20.0
        let ageTo = userDefaults.object(forKey: kAGETO) as? Float ?? 50.0

        ageFromSlider.value = ageFrom
        ageToSlider.value = ageTo

        self.ageFromLbl.text = "Age from " + String(format: "%.0f", ageFrom)
        self.ageToLbl.text = "Age to " + String(format: "%.0f", ageTo)
    }
    //MARK: - Setup

    private func setupBackgrounds() {
        profileCellBackgroundView.clipsToBounds = true
        profileCellBackgroundView.layer.cornerRadius = 100
        profileCellBackgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

        aboutMeView.layer.cornerRadius = 10
    }

    private func showSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(editUserData))

        navigationItem.rightBarButtonItem = editingMode ? saveButton : nil
    }
    private func setupPickerView() {
        genderPickerView = UIPickerView()
        genderPickerView.delegate = self

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor().primary()
        toolBar.sizeToFit()


        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        doneButton.tintColor = .black

        toolBar.setItems([spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true

        lookingForTextField.inputAccessoryView = toolBar
        lookingForTextField.inputView = genderPickerView
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }

    //MARK: - LoadUserData

    private func loadUserData() {

        let currentUser = FUser.currentUser()!

        FileStorage.donwloadImage(imageUrl: currentUser.avatarLink) { (image) in
            
        }

        nameAgeLbl.text = currentUser.username + ", \(currentUser.dateOfBirth.interval(ofComponnent: .year, fromDate: Date()))"

        cityCountryLbl.text = currentUser.country + ", " + currentUser.city
        aboutMeTextView.text = currentUser.about != "" ? currentUser.about : "A little about me ..."
        breedTextField.text = currentUser.breed
        weightTextField.text = "\(currentUser.weight)"
        heightTextField.text = "\(currentUser.height)"
        cityTextField.text = currentUser.city
        countryTextField.text = currentUser.country
        genderTextField.text = currentUser.isMale ? "Male" : "Female"
        lookingForTextField.text = currentUser.lookingFor
        avatarImageView.image = UIImage(named: "avatar")?.circleMasked

        avatarImageView.image = currentUser.avatar?.circleMasked


    }

    //MARK: - Editing Mode
    private func updateEditingMode() {
        aboutMeTextView.isUserInteractionEnabled = editingMode
        breedTextField.isUserInteractionEnabled = editingMode
        heightTextField.isUserInteractionEnabled = editingMode
        weightTextField.isUserInteractionEnabled = editingMode
        genderTextField.isUserInteractionEnabled = editingMode
        cityTextField.isUserInteractionEnabled = editingMode
        countryTextField.isUserInteractionEnabled = editingMode
        lookingForTextField.isUserInteractionEnabled = editingMode
    }

    //MARK: - Helpers
    private func showKeyboard() {
        self.aboutMeTextView.becomeFirstResponder()
    }

    private func hideKeyboard() {
        self.view.endEditing(false)
    }

    //MARK: - FileStorage

    private func uploadAvatar(_ image: UIImage, completion : @escaping (_ avatarLink: String?) -> Void) {

        ProgressHUD.show()

        let fileDirectory = "Avatar/_" + FUser.currentId() + ".jpg"

        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            ProgressHUD.dismiss()
            //save file locally
            FileStorage.saveImageLocally(imageData: image.jpegData(compressionQuality: 0.8)! as NSData, fileName: FUser.currentId() )
            completion(avatarLink)
        }
    }

    private func uploadImages(images: [UIImage?]) {
        ProgressHUD.show()
        FileStorage.uploadImages(images) { (imageLinks) in
            ProgressHUD.dismiss()
            let currentUser = FUser.currentUser()!
            currentUser.imageLinks = imageLinks
            self.saveUserData(user: currentUser)
        }
    }

    //MARK: - Gallery

    private func showGallery(forAvatar: Bool) {

        uploadingAvatar = forAvatar

        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = forAvatar ? 1 : 10
        Config.initialTab = .imageTab

        self.present(gallery, animated: true, completion: nil)

    }

    //MARK: - AlertController
    private func showPictureOptions() {

        let alertController = UIAlertController(title: "Upload Picture", message: "You can change your Profile picture or upload more picture", preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Change Picture", style: .default, handler: { (alert) in
            self.showGallery(forAvatar: true)
        }))

        alertController.addAction(UIAlertAction(title: "Upload Picture", style: .default, handler: { (alert) in
            self.showGallery(forAvatar: false)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }

    private func showEditOptions() {

        let alertController = UIAlertController(title: "Edit Account", message: "You are about to edit sensitive informationn about your account", preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Change Email", style: .default, handler: { (alert) in
            self.showChanngeField(value: "Email")
        }))

        alertController.addAction(UIAlertAction(title: "Change Name", style: .default, handler: { (alert) in
            self.showChanngeField(value: "Name")
        }))
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (alert) in
            self.logOutUser()
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }

    private func showChanngeField(value: String) {
        let alertView = UIAlertController(title: "Updating \(value)", message: "Please write your \(value)", preferredStyle: .alert)

        alertView.addTextField { (textField) in
            self.alertTextField = textField
            self.alertTextField.placeholder = "New \(value)"
        }
        alertView.addAction(UIAlertAction(title: "Update", style: .destructive, handler: { (action) in
            self.updateUserWith(value: value)
        }))
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

    //MARK: - Change user info

    private func updateUserWith(value: String) {

        if alertTextField.text != "" {
            value == "Email" ? changeEmail() : changeUserName()

        } else {
            ProgressHUD.showError("\(value) is empty")
        }
    }

    private func changeEmail() {
        FUser.currentUser()?.updateUserEmail(newEmail: alertTextField.text!, completion: { (error) in

            if error == nil {
                if let currentUser = FUser.currentUser() {
                    currentUser.email = self.alertTextField.text!
                    self.saveUserData(user: currentUser)
                }
                ProgressHUD.showSucceed("Success!")
            } else {
                ProgressHUD.showError(error!.localizedDescription)
            }
        })
    }

    private func changeUserName() {
        if let currentUser = FUser.currentUser() {
            currentUser.username = alertTextField.text!

            saveUserData(user: currentUser)
            loadUserData()
        }
    }

    //MARK: - LogOut

    private func logOutUser() {
        FUser.logOutCurrentUser { (error) in
            if error == nil {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            } else {
                ProgressHUD.showError(error!.localizedDescription)
            }
        }
    }
}

extension ProfileTableViewController: GalleryControllerDelegate {

    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {

        if images.count > 0 {
            if uploadingAvatar {
                images.first!.resolve { (icon) in

                    if icon != nil {

                        self.editingMode = true
                        self.showSaveButton()

                        self.avatarImageView.image = icon?.circleMasked
                        self.profileImage = icon
                    } else {
                        ProgressHUD.showError("Could't select image!")
                    }
                }

            } else {
                Image.resolve(images: images) { (resolvedImages) in
                    self.uploadImages(images: resolvedImages)
                }
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ProfileTableViewController : UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return genderOptions[row]
    }

}
extension ProfileTableViewController : UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lookingForTextField.text = genderOptions[row]
    }

}

