import UIKit

class AsyncFaveViewController : UIViewController, ASCollectionViewDataSource, ASCollectionViewDelegate {
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    let collectionView: ASCollectionView
    var deck = Deck(deckSourceMode: .Faves)
    
    required init(coder aDecoder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 0.0;
        layout.minimumLineSpacing = 0.0;

        collectionView = ASCollectionView(frame: CGRectZero, collectionViewLayout: layout, asyncDataFetching: false)

        super.init(coder: aDecoder)
        
        collectionView.asyncDataSource = self
        collectionView.asyncDelegate = self
        collectionView.backgroundColor = UIColor.blackColor()

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);

        // GA
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Favorites")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)

        Flurry.logAllPageViewsForTarget(self.navigationController)
        Flurry.logEvent("Favorite Page Shown")

        let titleImage = UIImage(named: "fun-logo.png")
        let titleImageView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        titleImageView.contentMode = .ScaleAspectFit
        titleImageView.image = titleImage
        self.navigationItem.titleView = titleImageView
        
        let rvc = self.revealViewController()
        revealButtonItem.target = rvc
        revealButtonItem.action = "revealToggle:"
        navigationController!.navigationBar.addGestureRecognizer(rvc.panGestureRecognizer())
        weak var weakSelf = self
        deck.fetch() {
            dispatch_async(dispatch_get_main_queue()) {
                if let strongSelf = weakSelf {
                    strongSelf.collectionView.reloadData()
                }
                NSLog("fetched faves")
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.frame = self.view.bounds
    }
    
    func collectionView(collectionView: ASCollectionView!, nodeForItemAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        //TODO make this safer
        let card = deck.cardAtIndex(UInt(indexPath.row)) as Card!
        let faveNode = FaveNode(thumbnailURL:NSURL(string:card.gifUrlPreview!)!)
        return faveNode
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return Int(deck.count())
    }
    
    func collectionView(collectionView: ASCollectionView!, willBeginBatchFetchWithContext context: ASBatchContext!) {
        let deckCount = deck.count()
        deck.fetch { [weak self]() -> Void in
            if let strongSelf = self {
                let newDeckCount = strongSelf.deck.count()
                var indexPaths: Array<NSIndexPath> =  []
                for index in deckCount ..< newDeckCount {
                    indexPaths.append(NSIndexPath(forRow: Int(index), inSection: 0))
                }
                
                strongSelf.collectionView.insertItemsAtIndexPaths(indexPaths);
            }
            context.completeBatchFetching(true)
        }
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        self.performSegueWithIdentifier("detail", sender: deck.cardAtIndex(UInt(indexPath!.row)))
    }
    
    func collectionViewLockDataSource(collectionView: ASCollectionView!) {
        //What to do?
    }
    
    func collectionViewUnlockDataSource(collectionView: ASCollectionView!) {
        //What to do?
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail" {
            let card = sender as Card
            let vc = segue.destinationViewController as DetailViewController
            vc.card = card
        }
    }
}

class FaveNode :  ASCellNode {
    let imageNode: ASNetworkImageNode
    let kCellInnerPadding = CGFloat(5.0)
    
    init(thumbnailURL: NSURL) {
        imageNode = ASNetworkImageNode()
        super.init()
        
        let cornerRadius = CGFloat(10.0)
        
        self.backgroundColor = UIColor.blackColor()
        imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
        imageNode.cornerRadius = cornerRadius
        imageNode.URL = thumbnailURL
        imageNode.contentMode = .ScaleAspectFit
        imageNode.imageModificationBlock = { [weak self](image: UIImage!) -> UIImage in
            let rect = CGRect(origin: CGPointZero, size:image.size)
            UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.mainScreen().scale);
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            image.drawInRect(rect)
            let                modifiedImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
            UIGraphicsEndImageContext();
            
            return modifiedImage
        }
        self.addSubnode(imageNode)
    }
    
    func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let availableWidth = constrainedSize.width / 3.0;
        
        return CGSizeMake(availableWidth, availableWidth)
    }
    
    func layout() {
        imageNode.frame = CGRectMake(kCellInnerPadding, kCellInnerPadding, self.calculatedSize.width - 2.0 * kCellInnerPadding, self.calculatedSize.height - 2.0 * kCellInnerPadding)
    }
}
