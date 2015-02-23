import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIView!
    
    var card: Card?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let gifView = GifView(frame: imageView.bounds, gifUrl: card!.gifvUrl!)
        imageView.addSubview(gifView)
        gifView.caption.text = self.card!.caption!
        
//        gifView.layer.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.2, alpha: 1.0).CGColor
//        gifView.layer.cornerRadius = 10.0;
//        gifView.layer.shadowColor = UIColor.blackColor().CGColor
//        gifView.layer.shadowOpacity = 0.33
//        gifView.layer.shadowOffset = CGSizeMake(0, 1.5)
//        gifView.layer.shadowRadius = 4.0
    }
    @IBAction func shareButtonWasPressed(sender: AnyObject) {
        let avc = UIActivityViewController(activityItems: [card!.caption!, card!.shareUrl()], applicationActivities: nil)
        navigationController?.presentViewController(avc, animated: true, completion: { () -> Void in
            NSLog("shared")
        })
    }
}
