import UIKit

class ViewController: UIViewController, ZLSwipeableViewDataSource, ZLSwipeableViewDelegate {
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var deck = Deck()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        swipeableView.dataSource = self
        swipeableView.delegate = self
        
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
    
    // ZLSwipeableViewDelegate
    func swipeableView(swipeableView: ZLSwipeableView!, didStartSwipingView view: UIView!, atLocation location: CGPoint) {
//        NSLog("swipe start")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didEndSwipingView view: UIView!, atLocation location: CGPoint) {
//        NSLog("swipe end")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didSwipeLeft view: UIView!) {
//        NSLog("did swipe left")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didSwipeRight view: UIView!) {
//        NSLog("did swipe right")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, swipingView view: UIView!, atLocation location: CGPoint, translation: CGPoint) {
    }
    
    // ZLSwipeableViewDataSource
    func nextViewForSwipeableView(swipeableView: ZLSwipeableView!) -> UIView! {
        if let card = self.deck.nextCard() {
            var view = GifView(frame: swipeableView.bounds)
        
            view.gifUrl = card.url!
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

