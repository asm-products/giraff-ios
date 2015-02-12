import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIView!
    
    var caption: String?
    var gifUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gifView = GifView(frame: imageView.frame)
        gifView.gifUrl = self.gifUrl!
        gifView.caption.text = self.caption!
        imageView.addSubview(gifView)
        
        gifView.layer.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.2, alpha: 1.0).CGColor
        gifView.layer.cornerRadius = 10.0;
        gifView.layer.shadowColor = UIColor.blackColor().CGColor
        gifView.layer.shadowOpacity = 0.33
        gifView.layer.shadowOffset = CGSizeMake(0, 1.5)
        gifView.layer.shadowRadius = 4.0

    }
}
