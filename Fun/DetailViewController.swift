import UIKit

class DetailViewController: GAITrackedViewController {

    @IBOutlet weak var imageView: UIView!
    
    var card: Card?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.screenName = "Datail"
        
        let gifView = GifCollectionViewCell(frame:imageView.bounds)
        gifView.gifUrl = card!.gifvUrl!
        gifView.addAnimatedImage()

        imageView.addSubview(gifView)
        gifView.caption.text = self.card!.caption!
        gifView.shouldPlay = true
        
        
//        view.layer.backgroundColor = UIColor.whiteColor().CGColor
//        view.layer.cornerRadius = 10.0
//        view.layer.shadowColor = UIColor.blackColor().CGColor
//        view.layer.shadowOpacity = 0.33
//        view.layer.shadowOffset = CGSizeMake(0, 1.5)
//        view.layer.shadowRadius = 4.0

//        gifView.layer.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.2, alpha: 1.0).CGColor
        gifView.layer.backgroundColor = UIColor.whiteColor().CGColor
        gifView.layer.cornerRadius = 10.0;
        gifView.layer.shadowColor = UIColor.blackColor().CGColor
        gifView.layer.shadowOpacity = 0.33
        gifView.layer.shadowOffset = CGSizeMake(0, 1.5)
        gifView.layer.shadowRadius = 4.0
        gifView.frame = imageView.bounds
        gifView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    }
    
    @IBAction func shareButtonWasPressed(sender: AnyObject) {
        let avc = UIActivityViewController(activityItems: [card!.caption!, card!.shareUrl()], applicationActivities: nil)
        navigationController?.presentViewController(avc, animated: true, completion: { () -> Void in
            NSLog("shared")
        })
    }
}
