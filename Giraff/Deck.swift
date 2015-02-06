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
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(NSURL(string:"http://55db6557.ngrok.com/images")!) {(data, response, error) in
            if error != nil {
                println("can't connect to server :(")
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                let images = json["images"] as NSArray
                var cards = MTLJSONAdapter.modelsOfClass(Card.self, fromJSONArray: images, error: nil)
                for card in cards {
                    self.cards.append(card as Card)
                }
                callback()
            }
        }
        task.resume()

    }
    
}
