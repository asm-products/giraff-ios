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
        get("/images") {(json:NSDictionary) -> Void in
            let images = json["images"] as NSArray
            callback(images)
        }
    }
    
    func fetchFaves(callback: (NSArray) -> Void) {
        get("/images/favorites") {(json:NSDictionary) -> Void in
            let images = json["images"] as NSArray
            callback(images)
        }
    }

    
    func imagePassed(imageId:NSString) {
        post("/images/\(imageId)/passes")
    }

    func imageFaved(imageId:NSString) {
        post("/images/\(imageId)/favorites")
    }

    
    func get(url:NSString, callback: (NSDictionary) -> Void) {
        request("GET", url: url) {(data:NSData) -> Void in
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
            callback(json)
        }
    }
    
    func post(url:NSString) {
        request("POST", url: url) {(NSData) -> Void in
            
        }
    }
    
    func request(httpMethod:String, url:String, callback: (NSData) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = "".join([apiUrl, url])
        let request = NSMutableURLRequest(URL: NSURL(string:url)!)
        request.HTTPMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(distinctId, forHTTPHeaderField: "X-User-Token")
        NSLog("%@ %@", httpMethod, url)
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            var httpResponse = response as NSHTTPURLResponse?
            if error != nil {
                NSLog("Failed to connect to server: %@", error)
            } else if httpResponse!.statusCode != 200 {
                let message = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse!.statusCode)
                NSLog("Server error: %d – %@", httpResponse!.statusCode, message)
            } else {
                NSLog("%@ %@ – %d", httpMethod, url, httpResponse!.statusCode)
                callback(data)
            }
        }
        task.resume()

    }
}