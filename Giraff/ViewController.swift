import UIKit

class ViewController: UIViewController, ZLSwipeableViewDataSource, ZLSwipeableViewDelegate {
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var deck = Deck()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
        let titleImage = UIImage(named: "fun-logo.png")
        let titleImageView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        titleImageView.contentMode = .ScaleAspectFit
        titleImageView.image = titleImage
        self.navigationItem.titleView = titleImageView

        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        swipeableView.dataSource = self
        swipeableView.delegate = self
        swipeableView.backgroundColor = UIColor.clearColor()
        
        deck.fetch() {
            dispatch_async(dispatch_get_main_queue()) {
                self.swipeableView.discardAllSwipeableViews()
                self.swipeableView.loadNextSwipeableViewsIfNeeded()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        swipeableView.setNeedsLayout()
        swipeableView.layoutIfNeeded()
    }
    
    @IBAction func refreshButtonWasPressed(sender: AnyObject) {
        deck.reset()
        self.swipeableView.discardAllSwipeableViews()
        self.swipeableView.loadNextSwipeableViewsIfNeeded()
    }

    @IBAction func faveButtonWasPressed(sender: AnyObject) {
        swipeableView.swipeTopViewToRight()
    }
    
    @IBAction func passButtonWasPressed(sender: AnyObject) {
        swipeableView.swipeTopViewToLeft()
    }
    
    // ZLSwipeableViewDelegate
    func swipeableView(swipeableView: ZLSwipeableView!, didStartSwipingView view: UIView!, atLocation location: CGPoint) {
//        NSLog("swipe start")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didEndSwipingView view: UIView!, atLocation location: CGPoint) {
//        NSLog("swipe end")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didSwipeLeft view: UIView!) {
        let gifView = view as GifView
        NSLog("\(gifView.imageId) passed")
        FunSession.sharedSession.imagePassed(gifView.imageId!)
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didSwipeRight view: UIView!) {
        let gifView = view as GifView
        NSLog("\(gifView.imageId) faved")
        FunSession.sharedSession.imageFaved(gifView.imageId!)
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, swipingView view: UIView!, atLocation location: CGPoint, translation: CGPoint) {
    }
    
    // ZLSwipeableViewDataSource
    func nextViewForSwipeableView(swipeableView: ZLSwipeableView!) -> UIView! {
        if let card = self.deck.nextCard() {
            var view = GifView(frame: swipeableView.bounds)
        
            view.gifUrl = card.url!
            view.imageId = card.id!
            view.caption.text = card.caption!

            view.layer.backgroundColor = UIColor.whiteColor().CGColor
            view.layer.cornerRadius = 10.0;
            view.layer.shadowColor = UIColor.blackColor().CGColor
            view.layer.shadowOpacity = 0.33
            view.layer.shadowOffset = CGSizeMake(0, 1.5)
            view.layer.shadowRadius = 4.0
            view.layer.shouldRasterize = true
            
            return view
        }
        return nil
    }
}

