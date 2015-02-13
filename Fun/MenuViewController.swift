import UIKit

class MenuViewController: UIViewController, FBLoginViewDelegate {
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fbLoginView.delegate = self
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        NSLog("Facebook logged out")
        revealViewController().dismissViewControllerAnimated(true, completion: nil)
    }
}
