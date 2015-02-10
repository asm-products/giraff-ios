import Foundation

class Deck : NSObject {
    var cards = [Card]()
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
    }
    
    func fetch(callback: () -> Void) {
        FunSession.sharedSession.fetchFaves() {(images) -> Void in
            var cards = MTLJSONAdapter.modelsOfClass(Card.self, fromJSONArray: images, error: nil)
            for card in cards {
                self.cards.append(card as Card)
            }
            callback()
        }
    }
}
