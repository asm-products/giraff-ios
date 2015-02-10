import Foundation

class Card : MTLModel, MTLJSONSerializing {
    var id:String?
    var caption:String?
    var url:String?
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["id":"id",
                "caption":"name",
                "url":"original_source"]
    }
}