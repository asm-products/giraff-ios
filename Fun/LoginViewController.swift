import UIKit

class LoginViewController: GAITrackedViewController, FBLoginViewDelegate {
    @IBOutlet weak var loginView: FBLoginView!
    @IBOutlet weak var bgImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Login"
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self
        
        if let image = launchImage() {
            bgImage.image = image
            self.view.bringSubviewToFront(loginView)
        }
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        NSLog("Facebook login successful");
        GAI.sharedInstance().defaultTracker
            .send(GAIDictionaryBuilder.createEventWithCategory("auth", action: "fb_login_success", label:"Facebook Login Successful", value:nil).build())

        User.currentUser.facebookName = user.objectForKey("name") as? String
        User.currentUser.facebookID = user.objectForKey("id") as? String
        User.currentUser.getFacebookProfilePicture { _ in
            
        }
        
        var loginEmail: String;
        if let email = user.objectForKey("email") as? String {
            loginEmail = email;
        }
        else {
            loginEmail = "\(User.currentUser.facebookID!)@facebook.com"
        }
        
        FunSession.sharedSession.signIn(loginEmail) {
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
        let fileName = launchImageFileName()
        if let file = NSBundle.mainBundle().pathForResource(fileName, ofType: "png") {
            return UIImage(contentsOfFile: file)!
        }
        return nil
    }
    
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
}
