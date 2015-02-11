import UIKit
import MediaPlayer

class GifView: UIView {
    var animatedView:FLAnimatedImageView!
    var caption:UILabel!
    var mpc:MPMoviePlayerController!
    var imageId:NSString? // Not sure if this belongs here, but helps us know which Image is associated with this view
    var task:NSURLSessionDataTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCaption()
        addAnimatedImageWithSpinner()
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
    
    
    
    
    func addCaption() {
        self.caption = UILabel(frame: CGRectMake(0, 0, self.bounds.width, 50))
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
        
        self.animatedView.animatedImage = spinnerImage
        
        self.addSubview(animatedView)
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
            weak var myAnimatedView : FLAnimatedImageView? = self.animatedView
            downloadData(NSURL(string: gifUrl)) {(data, error) in
                if error != nil {
                    NSLog("download error: %@", error!)
                } else {
                    if let myConcreteAnimatedView = myAnimatedView {
                        myConcreteAnimatedView.animatedImage = FLAnimatedImage(animatedGIFData: data)
                    }
                }
            }
        }
    }
    
    func downloadData(url: NSURL!, callback: (NSData, String?) -> Void) {
        var session = NSURLSession.sharedSession()
        task = session.dataTaskWithURL(url) {(data, response, error) in
            if error != nil {
                callback(NSData(), error.localizedDescription)
            } else {
                callback(data, nil)
            }
        }
        task!.resume()
    }
}
