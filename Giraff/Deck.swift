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
        var plist = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist")
        var config = NSDictionary(contentsOfFile: plist!)!
        var apiUrl = config["FUN_API_URL"] as NSString
        var imagesPath = apiUrl + "/images"
        
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(NSURL(string:imagesPath)!) {(data, response, error) in
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
