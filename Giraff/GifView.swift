import UIKit
import MediaPlayer

class GifView: UIView {
    var animatedView:FLAnimatedImageView!
    var mpc:MPMoviePlayerController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSpinner()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setSpinner() {
        NSLog("Setting spinner")
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
            
            downloadData(NSURL(string: gifUrl)) {(data, error) in
                if error != nil {
                    println("download error", error)
                } else {
                    println("got gif!")
                    self.animatedView.animatedImage = FLAnimatedImage(animatedGIFData: data)
                }
            }
        }
    }
    
    func downloadData(url: NSURL!, callback: (NSData, String?) -> Void) {
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(url) {(data, response, error) in
            if error != nil {
                callback(NSData(), error.localizedDescription)
            } else {
                callback(data, nil)
            }
        }
        task.resume()
    }
}
