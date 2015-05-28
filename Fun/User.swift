import Foundation

let UserKey = "FunCurrentUser"
class User: NSObject, NSCoding {
    class var currentUser: User {
        if let user = cachedUser() {
            return user
        } else {
            return User()
        }
    }
    
    class func cachedUser() -> User? {
        if let encodedObject = NSUserDefaults.standardUserDefaults().objectForKey(UserKey) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(encodedObject) as? User
        }
        return nil
    }
    
    class func removeCache() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: UserKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    var email: String? { didSet { cache() } }
    var facebookName: String? { didSet { cache() } }
    var facebookID: String? { didSet { cache() } }
    var facebookProfilePictureURL: String? {
        if let id = facebookID {
            return "http://graph.facebook.com/\(id)/picture?type=large"
        }
        
        return nil
    }
    var didLoginWithFacebook: Bool = false {didSet { cache() }}

    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObjectForKey("email") as? String
        self.facebookName = aDecoder.decodeObjectForKey("facebookName") as? String
        self.facebookID = aDecoder.decodeObjectForKey("facebookID") as? String
        self.didLoginWithFacebook = aDecoder.decodeObjectForKey("didLoginWithFacebook") as! Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let email = self.email {
            aCoder.encodeObject(email, forKey: "email")
        }
        if let facebookName = self.facebookName {
            aCoder.encodeObject(facebookName, forKey: "facebookName")
        }
        if let facebookID = self.facebookID {
            aCoder.encodeObject(facebookID, forKey: "facebookID")
        }

        aCoder.encodeObject(didLoginWithFacebook, forKey: "didLoginWithFacebook")
    }
    
    func getFacebookProfilePicture(callback: (image: UIImage?) -> Void) {
        var cachesDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as? NSURL
        var facebookProfilePictureCachesURL = cachesDirectoryURL?.URLByAppendingPathComponent("facebookProfilePicture\(self.facebookID).jpg")
        
        if  let path = facebookProfilePictureCachesURL?.path {
            var isPictureCached = NSFileManager.defaultManager().fileExistsAtPath(path)
            
            if isPictureCached {
                if let data = NSData(contentsOfFile: path) {
                    callback(image: UIImage(data: data))
                    return
                }
            }
        }
        
        if let facebookProfilePictureURL = self.facebookProfilePictureURL {
            if let url = NSURL(string: facebookProfilePictureURL) {
                NSURLSession.sharedSession().dataTaskWithURL(url) {
                    (data: NSData!, response: NSURLResponse!, error: NSError!) in
                    if error == nil {
                        if  let path = facebookProfilePictureCachesURL?.path {
                            var isPictureCachedNow = NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: nil)
                            println("isPictureCachedNow: \(isPictureCachedNow)")
                            callback(image: UIImage(data: data))
                        }
                    }
                }.resume()
            }
        }
    }
    
    func cache() {
        var encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(encodedObject, forKey: UserKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}