import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    @IBOutlet weak var loginView: FBLoginView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        NSLog("Facebook already logged in")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        NSLog("Facebook login successful")
        var email = user.objectForKey("email") as String
        FunSession.sharedSession.signIn(email) {
            NSLog("API signin successful")
            self.performSegueWithIdentifier("loggedIn", sender: user)
        }
    }
}
