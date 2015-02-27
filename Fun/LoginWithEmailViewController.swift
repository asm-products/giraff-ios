import UIKit

protocol LoginWithEmailDelegate {
    func didLoginWithEmail()
}

class LoginWithEmailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    @IBOutlet weak var loginButton: DesignableButton!

    var delegate: LoginWithEmailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.dataValidator = ValidatorFactory.emailValidator
        passwordTextField.dataValidator = ValidatorFactory.passwordValidator
        
        loginButton.enabled = false
    }

    @IBAction func loginButtonDidPress(sender: AnyObject) {
//        TODO: Use the new login API with password and email
//        FunSession.sharedSession.signIn(emailTextField.text) {
            self.delegate?.didLoginWithEmail()
//            TODO: Show alert if login is not successful
//            self.presentAlert("Error", message: "Invalid Account")
//        }
    }
    
    func textFieldDidBeginEditing(textField: DesignableTextField) {
        textField.validated = .Unknown
    }
    
    func textFieldDidEndEditing(textField: DesignableTextField) {
        if SPXFormValidator.validateField(textField) {
            textField.validated = .Valid
        } else {
            textField.validated = .Invalid
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        var didResign = textField.resignFirstResponder()
        if !didResign {
            return false
        }
        
        if let field = textField as? DesignableTextField {
            field.nextTextField?.becomeFirstResponder()
        }
        
        if textField.tag == 1 && SPXFormValidator.validateFields([emailTextField, passwordTextField]) {
                loginButtonDidPress(textField)
        }
        
        return true
    }

    @IBAction func textFieldDidChangeEditing(sender: UITextField) {
        self.loginButton.enabled = SPXFormValidator.validateFields([emailTextField, passwordTextField])
    }
    
    func presentAlert(title: String, message: String) {
        var alert = UIAlertController(title: "Error", message: "Invalid Account", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}