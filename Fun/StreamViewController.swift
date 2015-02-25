import UIKit

class StreamViewController: UIViewController, ZLSwipeableViewDataSource, ZLSwipeableViewDelegate {
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    
    var deck = Deck(deckSourceMode: DeckSourceMode.NewGifs)
    var swipeStart: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let titleImage = UIImage(named: "fun-logo.png")
        let titleImageView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        titleImageView.contentMode = .ScaleAspectFit
        titleImageView.image = titleImage
        self.navigationItem.titleView = titleImageView

        let rvc = self.revealViewController()
        revealButtonItem.target = rvc
        revealButtonItem.action = "revealToggle:"
        navigationController!.navigationBar.addGestureRecognizer(rvc.panGestureRecognizer())

        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        swipeableView.dataSource = self
        swipeableView.delegate = self
        swipeableView.backgroundColor = UIColor.clearColor()
    
        fetchCardsAndUpdateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        swipeableView.setNeedsLayout()
        swipeableView.layoutIfNeeded()
    }
    
//    @IBAction func switchToFavesButtonWasPressed(sender: AnyObject) {
//        deck.deckSourceMode = DeckSourceMode.Faves
//        deck.reset()
//        fetchCardsAndUpdateView()
//    }

    @IBAction func faveButtonWasPressed(sender: AnyObject) {
        swipeableView.swipeTopViewToRight()
        let view = swipeableView.topSwipeableView() as GifCollectionViewCell
        view.shouldPlay = true
    }
    
    @IBAction func passButtonWasPressed(sender: AnyObject) {
        swipeableView.swipeTopViewToLeft()
        let view = swipeableView.topSwipeableView() as GifCollectionViewCell
        view.shouldPlay = true
    }

    @IBAction func shareButtonWasPressed(sender: AnyObject) {
        let view = swipeableView.topSwipeableView() as GifCollectionViewCell
        let card = deck.cardForId(view.imageId!)!
        let avc = UIActivityViewController(activityItems: [card.caption!, card.shareUrl()], applicationActivities: nil)
        navigationController?.presentViewController(avc, animated: true, completion: nil)
    }

    
    func fetchCardsAndUpdateView() {
        weak var mySwipeableView : ZLSwipeableView?  = self.swipeableView
        deck.fetch() {
            dispatch_async(dispatch_get_main_queue()) {
                if let myConcreteSwipeableView = mySwipeableView {
                    myConcreteSwipeableView.discardAllSwipeableViews()
                    myConcreteSwipeableView.loadNextSwipeableViewsIfNeeded()
                }
            }
        }
    }
    
    // ZLSwipeableViewDelegate
    func swipeableView(swipeableView: ZLSwipeableView!, didStartSwipingView view: UIView!, atLocation location: CGPoint) {
        swipeStart = location
        println("swipe start")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didEndSwipingView view: UIView!, atLocation location: CGPoint) {
        swipeStart = nil

        let gifView = view as GifCollectionViewCell
        gifView.passLabel.alpha = 0.0
        gifView.faveLabel.alpha = 0.0
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didSwipeView view: UIView!, inDirection direction: ZLSwipeableViewDirection) {
        let gifView = view as GifCollectionViewCell
        switch(direction) {
        case .Left:
            println("\(gifView.imageId) passed")
            FunSession.sharedSession.imagePassed(gifView.imageId!)
        case .Right:
            println("\(gifView.imageId) faved")
            FunSession.sharedSession.imageFaved(gifView.imageId!)
        default:
            println("Ignore swipe")
        }
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didSwipeRight view: UIView!) {
        let gifView = view as GifCollectionViewCell
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, swipingView view: UIView!, atLocation location: CGPoint, translation: CGPoint) {
        let minimalDrag = CGFloat(10.0)
        let maximumDrag = CGFloat(40.0)
        let gifView = view as GifCollectionViewCell
        if let concreteSwipeStart = swipeStart {
            let swipeDiff = location.x - concreteSwipeStart.x
            let absSwipeDiff = abs(swipeDiff)

            var alphaValue = CGFloat(0.0)
            if (absSwipeDiff > maximumDrag) {
                alphaValue = 1.0
            } else if (absSwipeDiff > minimalDrag) {
                alphaValue = (absSwipeDiff - minimalDrag) / (maximumDrag - minimalDrag)
            }

            if swipeDiff > 0 {
                gifView.faveLabel.alpha = alphaValue
                gifView.passLabel.alpha = 0.0
            } else if swipeDiff < 0 {
                gifView.faveLabel.alpha = 0.0
                gifView.passLabel.alpha = alphaValue
            } else {
                gifView.faveLabel.alpha = 0.0
                gifView.passLabel.alpha = 0.0
            }
        }
    }
    
    // ZLSwipeableViewDataSource
    func nextViewForSwipeableView(swipeableView: ZLSwipeableView!) -> UIView! {
        
        if let view = swipeableView.topSwipeableView() as? GifCollectionViewCell {
            view.shouldPlay = true
        }

        if let card = self.deck.nextCard() {
            var view = GifCollectionViewCell(frame:swipeableView.bounds)
            view.gifUrl = card.gifvUrl!
            dispatch_async(dispatch_get_main_queue()) { [weak view]() -> Void in
                if let strongView = view {
                    strongView.addAnimatedImage()
                }
            }
            
            view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        
            view.imageId = card.id!
            view.caption.text = card.caption!

            view.layer.backgroundColor = UIColor.whiteColor().CGColor
            view.layer.cornerRadius = 10.0
            view.layer.shadowColor = UIColor.blackColor().CGColor
            view.layer.shadowOpacity = 0.33
            view.layer.shadowOffset = CGSizeMake(0, 1.5)
            view.layer.shadowRadius = 4.0
            
            return view
        }

        return nil
    }
}

