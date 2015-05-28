import Foundation

private let _sharedSession = FunSession()
private let authentication_token_key = "authentication_token"

class FunSession {
    class var sharedSession: FunSession {
        return _sharedSession
    }
    
    let apiUrl:String
    
    init() {
        var plist = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist")
        var config = NSDictionary(contentsOfFile: plist!)!
        apiUrl = config["FUN_API_URL"] as! String
    }
    
    func signIn(email:String, password:String, callback: () -> Void) {
        request("POST", url: "/sessions", body:["email":email, "password":password]) {(data:NSData) in
            println("CALLED")
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
            println(json)
            NSUserDefaults.standardUserDefaults().setObject(json[authentication_token_key], forKey: authentication_token_key)
            NSUserDefaults.standardUserDefaults().synchronize()
            callback()
        }
    }

    func fbSignIn(email:String, authToken:String, callback: () -> Void) {
      request("POST", url: "/fbcreate", body:["email":email, "fb_auth_token":authToken]) {(data:NSData) in
        let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
        NSUserDefaults.standardUserDefaults().setObject(json[authentication_token_key], forKey: authentication_token_key)
        NSUserDefaults.standardUserDefaults().synchronize()
        callback()
      }
    }
  
    func fetchImages(callback: (NSArray) -> Void) {
        get("/images") {(json:NSDictionary) -> Void in
            let images = json["images"] as! NSArray
            callback(images)
        }
    }

    func fetchFaves(currentFavePage:Int,callback: (NSArray) -> Void) {
        get("/images/favorites?page=\(currentFavePage)") {(json:NSDictionary) -> Void in
            let images = json["images"] as! NSArray
            callback(images)
        }
    }
    
    func imagePassed(imageId:NSString) {
        post("/images/\(imageId)/passes")
    }

    func imageFaved(imageId:NSString) {
        post("/images/\(imageId)/favorites")
    }

    
    func get(url:String, callback: (NSDictionary) -> Void) {
        request("GET", url: url, body:nil) {(data:NSData) in
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
            callback(json)
        }
    }
    
    func post(url:String) {
        request("POST", url: url, body:nil) {NSData in
        }
    }
    
    func request(httpMethod:String, url:String, body:NSDictionary?, callback: (NSData) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = "".join([apiUrl, url])
        let request = NSMutableURLRequest(URL: NSURL(string:url)!)
        request.HTTPMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = authenticationToken() {
            request.addValue(token, forHTTPHeaderField: "X-User-Token")
        }
        
        if let data = body {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.allZeros, error: nil)
        }
        
        NSLog("%@ %@", httpMethod, url)
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            var httpResponse = response as! NSHTTPURLResponse?
            if error != nil {
                NSLog("Failed to connect to server: %@", error)
            } else if httpResponse!.statusCode != 200 {
                let message = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse!.statusCode)
                NSLog("Server error: %d – %@", httpResponse!.statusCode, message)
            } else {
                println("\(httpMethod) \(url) - \(httpResponse!.statusCode)")
                callback(data)
            }
        }
        task.resume()
    }
    
    func authenticationToken() -> String? {
        if let token = NSUserDefaults.standardUserDefaults().stringForKey(authentication_token_key) {
            return token
        }
        return UIDevice.currentDevice().identifierForVendor.UUIDString
    }

    func deletePersistedAuthenticationToken() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: authentication_token_key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func authenticationTokenExists() -> Bool {
        if let token = NSUserDefaults.standardUserDefaults().stringForKey(authentication_token_key) {
            return true;
        } else {
            return false;
        }
    }
}
