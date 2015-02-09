import Foundation

private let _sharedSession = FunSession()

class FunSession {
    class var sharedSession: FunSession {
        return _sharedSession
    }
    
    var apiUrl:NSString
    
    init() {
        var plist = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist")
        var config = NSDictionary(contentsOfFile: plist!)!
        apiUrl = config["FUN_API_URL"] as NSString
    }
    
    func fetchImages(callback: (NSArray) -> Void) {
        let imagesPath = apiUrl + "/images"
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(NSURL(string:imagesPath)!) {(data, response, error) in
            if error != nil {
                println("can't connect to server :(")
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                let images = json["images"] as NSArray
                callback(images)
            }
        }
        task.resume()

    }
}