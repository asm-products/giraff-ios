import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate, LoginWithEmailDelegate, SignUpWithEmailDelegate {
    @IBOutlet weak var loginView: FBLoginView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailLoginView: UIView!
    @IBOutlet weak var emailLoginLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self
        
//        TODO: We need launch images without logos
//        if let image = launchImage() {
//            bgImage.image = image
//        }
    }

    override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
    }

    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        NSLog("Facebook login successful")
        var email = user.objectForKey("email") as String

        User.currentUser.facebookName = user.objectForKey("name") as? String
        User.currentUser.facebookID = user.objectForKey("id") as NSString
        User.currentUser.getFacebookProfilePicture { _ in
            
        }
        FunSession.sharedSession.signIn(email) {
            NSLog("API signin successful")
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("loggedIn", sender: self)
            }
        }
    }

    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        loginView.hidden = false
    }
    
    func launchImage() -> UIImage? {
        func launchImageFileName() -> String {
            switch(UIScreen.mainScreen().bounds.size.height) {
            case 568:
                return "LaunchImage-700-568h@2x"
            case 667:
                return "LaunchImage-800-667h@2x"
            case 736:
                return "LaunchImage-800-Portrait-736h@3x"
            default:
                return "LaunchImage-700@2x"
            }
        }
        
        let fileName = launchImageFileName()
        if let file = NSBundle.mainBundle().pathForResource(fileName, ofType: "png") {
            return UIImage(contentsOfFile: file)!
        }
        return nil
    }
    
    @IBAction func cancelLogin(unwindSegue: UIStoryboardSegue) {
        
    }
    
    func didLoginWithEmail() {
        println("API login successful")
//        self.dismissViewControllerAnimated(false, completion: nil)
//        self.performSegueWithIdentifier("loggedIn", sender: self)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("here")
            self.performSegueWithIdentifier("loggedIn", sender: self)
        })
        println("here")
    }
    
    func didSignUpWithEmail() {
        println("API sign up successful")
//        self.dismissViewControllerAnimated(false, completion: nil)
//        self.performSegueWithIdentifier("loggedIn", sender: self)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("here")
            self.performSegueWithIdentifier("loggedIn", sender: self)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "presentLoginWithEmail") {
            if let loginWithEmailViewController = segue.destinationViewController as? LoginWithEmailViewController {
                loginWithEmailViewController.delegate = self
            }
        } else if segue.identifier == "presentSignUpWithEmail" {
            if let signUpWithEmailViewController = segue.destinationViewController as? SignUpWithEmailViewController {
                signUpWithEmailViewController.delegate = self
            }
        }
    }
    

}
