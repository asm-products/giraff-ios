import Foundation

enum DeckSourceMode {
    case NewGifs, Faves
}

class Deck : NSObject {
    let FETCH_BUFFER:UInt = 10
    
    var cards = M13MutableOrderedDictionary()
    var deckSourceMode = DeckSourceMode.NewGifs
    var currentIndex:UInt = 0
    var currentFavePage: Int = 1

    
    init(deckSourceMode:DeckSourceMode) {
        super.init()
        self.deckSourceMode = deckSourceMode
    }
    
    func count() -> UInt {
        return self.cards.count()
    }
    
    func nextCard() -> Card? {
        if currentIndex >= self.cards.count() {
            return nil
        }
        let card = self.cards.objectAtIndex(currentIndex) as! Card
        currentIndex++
        
        if (cards.count() - currentIndex < FETCH_BUFFER) {
            fetch(nil)
        }
        return card
    }
    
    func cardForId(id:String) -> Card? {
        return self.cards.objectForKey(id) as! Card?
    }
    
    func cardAtIndex(index:UInt) -> Card? {
        return self.cards.objectAtIndex(index) as! Card?
    }
    
    func currentCard() -> Card? {
        return self.cards.objectAtIndex(self.currentIndex) as! Card?
    }
    
    func reset() {
        currentIndex = 0
        cards.removeAllObjects()
    }
    
    func fetch(callback: (() -> Void)!) {
        let imageHandler:(NSArray) -> Void = {[weak self](images) in
            if let strongSelf = self {
                let cards = MTLJSONAdapter.modelsOfClass(Card.self, fromJSONArray: images as [AnyObject], error: nil)
                for card in cards {
                    //Do not enter duplicate entries
                    if (strongSelf.cards.objectForKey((card as! Card).id) == nil) {
                        strongSelf.cards.addObject(card, pairedWithKey: (card as! Card).id)
                    }
                }
                if callback != nil {
                    callback()
                }
            }
        }
        
        switch(deckSourceMode) {
        case .NewGifs:
            FunSession.sharedSession.fetchImages(imageHandler)
            break
        case .Faves:
            FunSession.sharedSession.fetchFaves(currentFavePage, callback: imageHandler)
            currentFavePage++
            break
        }
    }
}
