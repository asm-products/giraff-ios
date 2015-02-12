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

    var passLabel:UIImageView!
    var faveLabel:UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        addProgressIndicator()
        addCaption()
        addAnimatedImage()
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
        self.animatedView = FLAnimatedImageView(frame: CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        self.animatedView.contentMode = .ScaleAspectFit
        self.animatedView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
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
        
        self.animatedView.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height - margin)
        
        var progress_width = self.bounds.width
        if self.bounds.width > self.bounds.height {
            progress_width = self.bounds.height
        }
        progressIndicator.frame = CGRectMake(0, 0, progress_width/2, progress_width/2)
        progressIndicator.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)

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
      self.progressIndicator.progress = progress
    })

  }
}
