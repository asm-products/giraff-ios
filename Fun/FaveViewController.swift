import UIKit

class FaveViewController: UIViewController {
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleImage = UIImage(named: "fun-logo.png")
        let titleImageView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        titleImageView.contentMode = .ScaleAspectFit
        titleImageView.image = titleImage
        self.navigationItem.titleView = titleImageView
        
        let rvc = self.revealViewController()
        revealButtonItem.target = rvc
        revealButtonItem.action = "revealToggle:"
        navigationController!.navigationBar.addGestureRecognizer(rvc.panGestureRecognizer())
    }
}
