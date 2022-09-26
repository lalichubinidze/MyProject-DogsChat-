

import UIKit
import ProgressHUD

final class RegisterViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var passworTextField: UITextField!
    @IBOutlet weak var confrimPasswordTextField: UITextField!
    @IBOutlet weak var genderSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var backgroundImageView: UIImageView!

    //MARK: - Vars
    var isMale = true

    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setupBackgroundTouch()
    }
    
    //MARK: - IBActions

    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        if isTextDataImputed() {
            if passworTextField.text! == confrimPasswordTextField.text! {
                registerUser()
            } else {
                ProgressHUD.showError("Password don't match!")
            }

        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }

    @IBAction func loginBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func genderSegmentValueChanged(_ sender: UISegmentedControl) {
        isMale = sender.selectedSegmentIndex == 0
    }

    //MARK: - Setup

    private func setupBackgroundTouch() {
        backgroundImageView.isUserInteractionEnabled = false
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(backgroundTap))
        backgroundImageView.addGestureRecognizer(tapGesture)
    }

    @objc func backgroundTap() {
        dismissKeyboard()
    }

    //MARK: - Helpers
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }

    private func isTextDataImputed() -> Bool {

        return usernameTextField.text != "" && emailTextField.text != "" && cityTextField.text != "" && passworTextField.text != "" && confrimPasswordTextField.text != ""
    }
    //MARK: - RegisterUser
    private func registerUser() {

        ProgressHUD.show()

        FUser.registerUserWith(email: emailTextField.text!, passsword: passworTextField.text!, userName: usernameTextField.text!, city: cityTextField.text!, isMale: isMale, dateOfBirth: datePicker.date, completion: {
            error in

            if error == nil {
                ProgressHUD.showSuccess("Verification email sent!")
                self.dismiss(animated: true, completion: nil)
            } else {
                ProgressHUD.showError(error!.localizedDescription)
            }
        })
    }
}

