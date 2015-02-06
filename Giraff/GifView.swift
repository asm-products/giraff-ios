import UIKit
import MediaPlayer

class GifView: UIView {
    var animatedView:FLAnimatedImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSpinner()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setSpinner() {
        let path:String = NSBundle.mainBundle().pathForResource("spinner", ofType:"gif")! as NSString
        let data = NSData.dataWithContentsOfMappedFile(path) as NSData
        let spinnerImage = FLAnimatedImage(animatedGIFData: data)
        
        self.animatedView = FLAnimatedImageView(frame: self.bounds)
        self.animatedView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.animatedView.animatedImage = spinnerImage
        
        self.addSubview(animatedView)
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
