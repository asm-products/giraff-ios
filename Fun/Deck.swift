import Foundation

enum DeckSourceMode {
    case NewGifs, Faves
}

class Deck : NSObject {
    let FETCH_BUFFER = 10
    
    var cards = M13MutableOrderedDictionary()
    var deckSourceMode = DeckSourceMode.NewGifs
    var currentIndex:UInt = 0
    
    func nextCard() -> Card? {
        if currentIndex >= self.cards.count() {
            return nil
        }
        let card = self.cards.objectAtIndex(currentIndex) as Card
        currentIndex++
        
        if (cards.count() - currentIndex < FETCH_BUFFER) {
            fetch(nil)
        }
        return card
    }
    
    func cardForId(id:String) -> Card? {
        return self.cards.objectForKey(id) as Card?
    }
    
    func reset() {
        currentIndex = 0
        cards.removeAllObjects()
    }
    
    func fetch(callback: (() -> Void)!) {
        let imageHandler:(NSArray) -> Void = {[unowned self](images) in
            let cards = MTLJSONAdapter.modelsOfClass(Card.self, fromJSONArray: images, error: nil)
            for card in cards {
                self.cards.addObject(card, pairedWithKey: (card as Card).id)
            }
            if callback != nil {
                callback()
            }
        }
        
        switch(deckSourceMode) {
        case .NewGifs:
            FunSession.sharedSession.fetchImages(imageHandler)
            break
        case .Faves:
            FunSession.sharedSession.fetchFaves(imageHandler)
            break
        }
    }
}
