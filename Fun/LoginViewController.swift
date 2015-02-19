import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    @IBOutlet weak var loginView: FBLoginView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailLoginView: UIView!
    @IBOutlet weak var emailLoginLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self
        
        if let image = launchImage() {
            bgImage.image = image
            self.view.bringSubviewToFront(loginView)
        }
      
      // keyboard
      var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
      center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
      center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
      
      var info:NSDictionary = notification.userInfo!
      var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
      
      var keyboardHeight:CGFloat = keyboardSize.height
      
      var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
      
      UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
        }, completion: nil)
    }
  
    func keyboardWillHide(notification: NSNotification) {
      var info:NSDictionary = notification.userInfo!
      var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
      
      var keyboardHeight:CGFloat = keyboardSize.height
      
      var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
      
      UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
        }, completion: nil)
    }
  
    override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
      NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
      NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
  
    func isValidEmail(testStr:String) -> Bool {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
      let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
      let result = range != nil ? true : false
      return result
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

    @IBAction func loginButtonPressed(sender: AnyObject) {
      if isValidEmail(emailField.text){
        FunSession.sharedSession.signIn(emailField.text) {
          NSLog("API signin successful")
          dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("loggedIn", sender: self)
          }
        }
      } else {
        var alert = UIAlertController(title: "Error", message: "Invalid Email", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
