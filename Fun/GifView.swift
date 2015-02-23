import UIKit
import MediaPlayer

class GifView: UIView {
    var animatedViewController:MPMoviePlayerController!
    var caption:UILabel!
    var imageId:NSString? // Not sure if this belongs here, but helps us know which Image is associated with this view
    var task:NSURLSessionDataTask?
    var imageBytes:NSMutableData?
    var totalBytesLength:Float64?
    var progressIndicator: CircleProgressView!
    private var gifUrl: NSString
    var passLabel:UIImageView!
    var faveLabel:UIImageView!

    init(frame: CGRect, gifUrl: String) {
        self.gifUrl = gifUrl
        super.init(frame: frame)
        addProgressIndicator()
        addCaption()
        addAnimatedImage()
        addPassLabel()
        addFaveLabel()
    }

    required init(coder aDecoder: NSCoder) {
        self.gifUrl = ""
        super.init(coder: aDecoder)
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        if let t = self.task {
            if t.state == NSURLSessionTaskState.Running {
                t.cancel()
            }
        }
    }

    func addProgressIndicator() {
      var progress_width = self.bounds.width
      progressIndicator = CircleProgressView(frame: CGRectMake(progress_width/4, progress_width/4, progress_width/2, progress_width/2))
      progressIndicator.trackFillColor = UIColor(red: 0.918, green: 0.714, blue: 0.129, alpha: 1.0)
      progressIndicator.backgroundColor = UIColor.clearColor()
      progressIndicator.trackBackgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
      self.addSubview(progressIndicator)
    }

    func addCaption() {
        self.caption = UILabel(frame: CGRectMake(0, self.bounds.height-50, self.bounds.width, 45))
        caption.textAlignment = NSTextAlignment.Center
        caption.numberOfLines = 0
        caption.lineBreakMode = NSLineBreakMode.ByWordWrapping
        caption.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        addSubview(caption)
    }

    func addAnimatedImage() {
        animatedViewController = MPMoviePlayerController(contentURL: NSURL(string: gifUrl))
        animatedViewController.backgroundView.backgroundColor = UIColor.whiteColor()
        let animatedView = animatedViewController.view
        animatedViewController.repeatMode = .One
        animatedViewController.controlStyle = .None
        animatedView.contentMode = .ScaleAspectFit
        animatedView.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height)
        animatedView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.addSubview(animatedView)
    }

    func addPassLabel() {
        let label = UIImageView(image: UIImage(named: "Pass"))
        label.center = CGPoint(x: self.bounds.width - (self.bounds.width / 3.0), y: self.bounds.height / 3.0)
        label.alpha = 0.0
        self.addSubview(label)

        passLabel = label
    }

    func addFaveLabel() {
        let label = UIImageView(image: UIImage(named: "Faved"))
        label.center = CGPoint(x: self.bounds.width / 3.0, y: self.bounds.height / 3.0)
        label.alpha = 0.0
        self.addSubview(label)

        faveLabel = label
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var margin:CGFloat = 50.0
        if caption.text == nil {
            margin = 0
        }

        self.animatedViewController.view.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height - margin)

        var progress_width = self.bounds.width
        if self.bounds.width > self.bounds.height {
            progress_width = self.bounds.height
        }
        progressIndicator.frame = CGRectMake(0, 0, progress_width/2, progress_width/2)
        progressIndicator.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)

    }
}
