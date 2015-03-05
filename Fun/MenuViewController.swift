import UIKit

class MenuViewController: UIViewController, FBLoginViewDelegate {
    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let facebookName = User.currentUser.facebookName {
            usernameLabel.text = facebookName.uppercaseString
        }
        
        if User.currentUser.didLoginWithFacebook {
            User.currentUser.getFacebookProfilePicture { image in
                if let facebookProfilePicture = image {
                    self.userProfileImageView.image = facebookProfilePicture
                }
            }
            fbLoginView.delegate = self
            logoutButton.hidden = true
        } else {
            if let email = User.currentUser.email {
                usernameLabel.text = email
            }
            fbLoginView.hidden = true
        }

    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        NSLog("Facebook logged out")
        self.logoutUser()
        revealViewController().dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logoutButtonDidPress(button: UIButton) {
        self.logoutUser()
        revealViewController().dismissViewControllerAnimated(true, completion: nil)
    }

    func logoutUser() {
        User.removeCache()
        FunSession.sharedSession.deletePersistedAuthenticationToken()
    }
}
