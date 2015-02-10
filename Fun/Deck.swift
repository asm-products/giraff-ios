import Foundation

enum DeckSourceMode {
    case NewGifs, Faves
}

class Deck : NSObject {
    var cards = [Card]()
    var deckSourceMode = DeckSourceMode.NewGifs
    var currentIndex = 0
    
    func nextCard() -> Card? {
        if currentIndex >= self.cards.count {
            return nil
        }
        let card = self.cards[currentIndex]
        currentIndex++
        return card
    }
    
    func reset() {
        currentIndex = 0
        cards.removeAll(keepCapacity: true)
    }
    
    func fetch(callback: () -> Void) {
        let imageHandler:(NSArray) -> Void = {(images) in
            var cards = MTLJSONAdapter.modelsOfClass(Card.self, fromJSONArray: images, error: nil)
            for card in cards {
                self.cards.append(card as Card)
            }
            callback()
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
