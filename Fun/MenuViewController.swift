import UIKit

class MenuViewController: UIViewController, FBLoginViewDelegate {
    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let facebookName = User.currentUser.facebookName {
            usernameLabel.text = facebookName.uppercaseString
        }
        
        User.currentUser.getFacebookProfilePicture { image in
            if let facebookProfilePicture = image {
                self.userProfileImageView.image = facebookProfilePicture
            }
        }

        fbLoginView.delegate = self
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        NSLog("Facebook logged out")
        User.removeCache()
        revealViewController().dismissViewControllerAnimated(true, completion: nil)
    }
}
