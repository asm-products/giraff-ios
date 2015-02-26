import UIKit
import AVFoundation
import MediaPlayer

class GifCollectionViewCell: UICollectionViewCell, NSURLSessionDataDelegate, NSURLSessionTaskDelegate{
    var caption:UILabel!
    var imageId:NSString? // Not sure if this belongs here, but helps us know which Image is associated with this view
    var task:NSURLSessionDataTask?
    var imageBytes:NSMutableData?
    var totalBytesLength:Float64?
    var progressIndicator: CircleProgressView!
    var gifUrl: NSString?
    var shouldPlay:Bool = false  {
        didSet {
            if let player = videoView!.player() {
                if (player.status == .ReadyToPlay && shouldPlay) {
                    player.play()
                } else if player.status == .ReadyToPlay {
                    player.pause()
                }
            }
        }
    }

    var passLabel:UIImageView!
    var faveLabel:UIImageView!
    var previewImageView:UIImageView!
    private var videoView:VideoView?
    
    typealias KVOContext = UInt8
    var MyObservationContext = KVOContext()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.videoView!.player()!.removeObserver(self, forKeyPath: "status", context: &MyObservationContext)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViewHierarchy()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.buildViewHierarchy()
    }

    private func buildViewHierarchy() {
        addPreviewImage()
        
        layer.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.2, alpha: 1.0).CGColor
        layer.cornerRadius = 10.0;
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.33
        layer.shadowOffset = CGSizeMake(0, 1.5)
        layer.shadowRadius = 4.0

        addVideoView()

        addCaption()
        addPassLabel()
        addFaveLabel()
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
        self.videoView!.hidden = false
        let player = AVPlayer(URL: NSURL(string:self.gifUrl!))
        player.muted = true
        self.videoView!.setPlayer(player)
            let options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old
            self.videoView!.player()?.addObserver(self, forKeyPath:"status", options: options, context: &MyObservationContext)

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "playerItemDidReachEnd:",
            name:AVPlayerItemDidPlayToEndTimeNotification,
            object: self.videoView!.player()?.currentItem)
        
        self.videoView!.player()?.actionAtItemEnd = .None
    }
    
    func addPreviewImage() {

        previewImageView = UIImageView(frame: self.bounds)
        previewImageView!.contentMode = .ScaleAspectFit
        previewImageView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(previewImageView!)
        
        addProgressIndicator()
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        let p = notification.object as AVPlayerItem;
        p.seekToTime(kCMTimeZero)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (self.videoView!.player()!.status == .ReadyToPlay && self.shouldPlay) {
            self.videoView!.player()!.play()
        }
    }
    
    func addVideoView() {
        videoView = VideoView(frame: self.bounds)
        videoView!.contentMode = .ScaleAspectFit
        videoView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(videoView!)
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

        var progress_width = self.bounds.width
        if self.bounds.width > self.bounds.height {
            progress_width = self.bounds.height
        }
        if progressIndicator != nil {
        progressIndicator.frame = CGRectMake(0, 0, progress_width/2, progress_width/2)
        progressIndicator.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        }

    }


    func downloadData(){
        var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        self.progressIndicator.hidden = false
        self.progressIndicator.progress = 0.000001
        self.previewImageView.image = nil
        task = session.dataTaskWithURL(NSURL(string:self.gifUrl!)!)
        task!.resume()
    }

  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
    completionHandler(NSURLSessionResponseDisposition.Allow)
    NSLog("response received: \(response.expectedContentLength) bytes")
    self.imageBytes = NSMutableData()
    self.totalBytesLength = Float64(response.expectedContentLength)
  }

  func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    if error != nil {
      NSLog("download error: %@", error!)
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if let imageBytes = self.imageBytes {
                let image = UIImage(data:imageBytes)
                if let loadedImage = image {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.previewImageView.image = loadedImage
                        self.progressIndicator.hidden = true
                    })
                }
            }
        })
      }
    }
//  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, willCacheResponse proposedResponse: NSCachedURLResponse, completionHandler: (NSCachedURLResponse!) -> Void) {
//    
//    let response = proposedResponse.response as NSHTTPURLResponse
//    var headers = response.allHeaderFields
//    headers["Cache-Control"] = "max-age=86400, private" // cache for a day
//    headers.removeValueForKey("Expires")
//    headers.removeValueForKey("s-maxage")
//    let newResponse = NSHTTPURLResponse(URL: response.URL!, statusCode: response.statusCode, HTTPVersion: "HTTP/1.1", headerFields: headers)
//    let cached = NSCachedURLResponse(response: newResponse!, data: proposedResponse.data, userInfo: headers, storagePolicy: NSURLCacheStoragePolicy.Allowed)
//    
//    completionHandler(cached)
//  }

  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    self.imageBytes!.appendData(data)
    var progress = (Float64(self.imageBytes!.length) / totalBytesLength!)
    NSLog("data received: %@", dataTask)

    dispatch_async(dispatch_get_main_queue(), {
      self.progressIndicator.progress = progress
    })
}

}
class VideoView: UIView {
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    func player() -> AVPlayer? {
        let playerLayer = self.layer as AVPlayerLayer
        return playerLayer.player
    }
    
    func setPlayer(player: AVPlayer) {
        let playerLayer = self.layer as AVPlayerLayer
        playerLayer.player = player
    }
}
