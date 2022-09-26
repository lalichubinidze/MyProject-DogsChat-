
import UIKit
import ProgressHUD

final class WelcomeViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setupBackgroundTouch()
    }

    //MARK: - IBActions
    @IBAction func forgotPasswordBtn(_ sender: Any) {
        if emailTextField.text != "" {
            FUser.resetPassword(email: emailTextField.text!) { (error) in

                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                } else {
                    ProgressHUD.showSuccess("Please cheach your email!")
                }
            }
        } else {
            ProgressHUD.showError("Please insert your email address.")
        }
    }

    @IBAction func loginBtn(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {

            ProgressHUD.show()

            FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in

                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                } else if isEmailVerified {

                    ProgressHUD.dismiss()
                    self.goToApp()

                } else {
                    ProgressHUD.showError("Please verify your email!")
                }
            }
        } else {
            ProgressHUD.showError("All fields are required!")
        }
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
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }

   //MARK: - Navigation
    private func goToApp() {

        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
}
