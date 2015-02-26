import UIKit

protocol SignUpWithEmailDelegate {
    func didSignUpWithEmail()
}

class SignUpWithEmailViewController: UIViewController {

    @IBOutlet weak var usernameTextField: DesignableTextField!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    @IBOutlet weak var signUpButton: DesignableButton!
    
    var delegate: SignUpWithEmailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.dataValidator = ValidatorFactory.usernameValidator
        emailTextField.dataValidator = ValidatorFactory.emailValidator
        passwordTextField.dataValidator = ValidatorFactory.passwordValidator
        
        signUpButton.enabled = true
    }

    @IBAction func signUpButtonDidPress(button: AnyObject) {
        // TODO: Use the new sign up API with password and email

//        FunSession.sharedSession.signIn(emailTextField.text) {
        
        self.delegate?.didSignUpWithEmail()


        
            //        TODO: Show alert if not successful
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
        
        if textField.tag == 1 && SPXFormValidator.validateFields([usernameTextField, emailTextField, passwordTextField]) {
                self.signUpButtonDidPress(textField)
        }
        
        return true
    }
    
    @IBAction func textFieldDidChangeEditing(sender: UITextField) {
        self.signUpButton.enabled = SPXFormValidator.validateFields([usernameTextField, emailTextField, passwordTextField])
    }
    
}
