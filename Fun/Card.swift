import Foundation

class Card : MTLModel, MTLJSONSerializing {
    var id:String?
    var caption:String?
    var url:String?
    var shortcode:String?
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["id":"id",
                "caption":"name",
                "url":"original_source",
                "shortcode":"shortcode"]
    }
    
    func shareUrl() -> String {
        let plist = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist")
        let config = NSDictionary(contentsOfFile: plist!)!
        let shareUrl = config["SHARE_URL"] as NSString
        return "".join([shareUrl, shortcode!])
    }
}