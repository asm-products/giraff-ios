import Foundation

private let _sharedSession = FunSession()

class FunSession {
    class var sharedSession: FunSession {
        return _sharedSession
    }
    
    let apiUrl:NSString
    let distinctId:NSString
    
    init() {
        var plist = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist")
        var config = NSDictionary(contentsOfFile: plist!)!
        apiUrl = config["FUN_API_URL"] as NSString
        distinctId = UIDevice.currentDevice().identifierForVendor.UUIDString
    }
    
    func fetchImages(callback: (NSArray) -> Void) {
        let imagesPath = apiUrl + "/images"
        
        get(imagesPath) {(json:NSDictionary) -> Void in
            let images = json["images"] as NSArray
            callback(images)
        }
    }
    
    func get(url:NSString, callback: (json:NSDictionary) -> Void) {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string:url)!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(distinctId, forHTTPHeaderField: "X-User-Token")
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            if error != nil {
                println("can't connect to server :(")
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                callback(json: json)
            }
        }
        task.resume()
    }
}