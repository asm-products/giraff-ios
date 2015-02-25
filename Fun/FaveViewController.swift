import UIKit

class FaveViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    
    var deck = Deck(deckSourceMode: DeckSourceMode.Faves)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerClass(GifCollectionViewCell.self, forCellWithReuseIdentifier: "gifCell")
        
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
                    strongSelf.collectionView!.reloadData()
                }
                NSLog("fetched faves")
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let gifView = collectionView.dequeueReusableCellWithReuseIdentifier("gifCell", forIndexPath: indexPath) as GifCollectionViewCell
        
        let card = deck.cardAtIndex(UInt(indexPath.row)) as Card!
        gifView.gifUrl = card.gifUrlPreview!
        gifView.task?.cancel()
        gifView.downloadData()
        
        return gifView
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(deck.count())
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = self.view.bounds.width / 3 - 10
        return CGSize(width: size, height: size)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail" {
            let cell = sender as UICollectionViewCell
            let indexPath = collectionView?.indexPathForCell(cell)!
            let vc = segue.destinationViewController as DetailViewController
            
            let card = deck.cardAtIndex(UInt(indexPath!.row)) as Card!
            
            vc.card = card
        }
    }
}
