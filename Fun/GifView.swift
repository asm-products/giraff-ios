import UIKit
import MediaPlayer

class GifView: UIView, NSURLSessionDataDelegate, NSURLSessionTaskDelegate{
    var animatedView:FLAnimatedImageView!
    var caption:UILabel!
    var mpc:MPMoviePlayerController!
    var imageId:NSString? // Not sure if this belongs here, but helps us know which Image is associated with this view
    var task:NSURLSessionDataTask?
    var imageBytes:NSMutableData?
    var totalBytesLength:Float64?
    var progressIndicator: CircleProgressView!
    var progressLabel: UILabel!

    var passLabel:UILabel!
    var faveLabel:UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        addProgressIndicator()
        addCaption()
        addAnimatedImageWithSpinner()
        addPassLabel()
        addFaveLabel()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
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
      progressIndicator.backgroundColor = UIColor.whiteColor()
      progressIndicator.trackBackgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
      self.addSubview(progressIndicator)

      progressLabel = UILabel(frame: CGRectMake(0, self.bounds.height/2-32.0, self.bounds.width, 32.0))
      progressLabel.font = UIFont(name: progressLabel.font.fontName, size: 32)
      progressLabel.textAlignment = .Center
      progressLabel.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
      progressLabel.alpha = 0.9
      addSubview(progressLabel)
    }

    func addCaption() {
        self.caption = UILabel(frame: CGRectMake(0, self.bounds.height-50, self.bounds.width, 50))
        caption.textAlignment = NSTextAlignment.Center
        caption.numberOfLines = 0
        caption.lineBreakMode = NSLineBreakMode.ByWordWrapping
        addSubview(caption)
    }

    func addAnimatedImageWithSpinner() {
        let path:String = NSBundle.mainBundle().pathForResource("spinner", ofType:"gif")! as NSString
        let data = NSData.dataWithContentsOfMappedFile(path) as NSData
        let spinnerImage = FLAnimatedImage(animatedGIFData: data)

        self.animatedView = FLAnimatedImageView(frame: self.bounds)
        self.animatedView.contentMode = UIViewContentMode.ScaleAspectFit

        self.addSubview(animatedView)
    }

    func addPassLabel() {
        let label = createBaseLabel()
        label.frame = CGRectMake(self.bounds.width - (self.bounds.width / 6) - 60, self.bounds.height / 4, 80, 50)
        label.text = NSLocalizedString("Pass", comment: "")
        label.textColor = UIColor.redColor()
        label.alpha = 0.0
        label.layer.borderColor = UIColor.redColor().CGColor
        self.addSubview(label)

        label.transform=CGAffineTransformMakeRotation(CGFloat( ( -25.0 * M_PI ) / 180.0 ))

        passLabel = label
    }

    func addFaveLabel() {
        let label = createBaseLabel()
        label.frame = CGRectMake(self.bounds.width / 6, self.bounds.height / 4, 80, 50)
        label.text = NSLocalizedString("Fave", comment: "")
        label.textColor = UIColor.greenColor()
        label.alpha = 0.0
        label.layer.borderColor = UIColor.greenColor().CGColor
        self.addSubview(label)

        label.transform=CGAffineTransformMakeRotation(CGFloat( ( 25.0 * M_PI ) / 180.0 ))


        faveLabel = label
    }

    func createBaseLabel() -> UILabel {
        let label = UILabel(frame: CGRectZero)
        label.textAlignment = NSTextAlignment.Center
        label.layer.borderWidth = 2.0
        label.layer.cornerRadius = 5.0

        return label
    }


    // Doesn't quite work, only 1 video shows, all others are black
    var mp4Url: NSString? = nil {
        didSet {
            self.animatedView.removeFromSuperview()

            mpc = MPMoviePlayerController()
            if let player = mpc {
                player.view.frame = self.bounds
                player.backgroundView.backgroundColor = UIColor.whiteColor()

                player.movieSourceType = MPMovieSourceType.Streaming
                player.contentURL = NSURL(string: mp4Url!)
                player.shouldAutoplay = false
                player.controlStyle = MPMovieControlStyle.None
                player.repeatMode = MPMovieRepeatMode.One
                player.prepareToPlay()

                addSubview(player.view)
            }
        }
    }

    var gifUrl: NSString = "" {
        didSet {
          NSLog("downloading %@", gifUrl)
          downloadData(NSURL(string: gifUrl))
        }
    }

    func downloadData(url: NSURL!){
        var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        task = session.dataTaskWithURL(url)
        task!.resume()
    }

  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
    completionHandler(NSURLSessionResponseDisposition.Allow)
    NSLog("response received: \(response.expectedContentLength) bytes")
    self.imageBytes = NSMutableData()
    self.totalBytesLength = Float64(response.expectedContentLength)
  }

  func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    weak var myAnimatedView : FLAnimatedImageView? = self.animatedView
    if error != nil {
      NSLog("download error: %@", error!)
      self.progressLabel.text = "Error"
    } else {
      if let myConcreteAnimatedView = myAnimatedView {
        myConcreteAnimatedView.animatedImage = FLAnimatedImage(animatedGIFData: self.imageBytes!)
        dispatch_async(dispatch_get_main_queue(), {
          self.progressIndicator.removeFromSuperview()
        })
      }
    }
  }

  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    self.imageBytes!.appendData(data)
    var progress = (Float64(self.imageBytes!.length) / totalBytesLength!)

    dispatch_async(dispatch_get_main_queue(), {
      self.progressLabel.text = "\(Int(progress * 100))%"
      self.progressIndicator.progress = progress
    })

  }
}
