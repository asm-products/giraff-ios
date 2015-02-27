import UIKit

private let passwordRegex = "^[a-zA-Z0-9_-]{6,32}$"
private let usernameRegex = "^[a-zA-Z0-9_-]{3,16}$"

class ValidatorFactory: NSObject {
    class var emailValidator: SPXCompoundDataValidator {
        let emptyValidator = SPXNonEmptyDataValidator()
        let emailValidator = SPXEmailDataValidator()
        
        let validators = NSOrderedSet(array: [emptyValidator, emailValidator])
        return SPXCompoundDataValidator(validators: validators, validationType: SPXCompoundDataValidationType.ValidatorValidateAll)
    }
    
    class var passwordValidator: SPXCompoundDataValidator {
        let emptyValidator = SPXNonEmptyDataValidator()
        let regexValidator = SPXRegexDataValidator(expression: passwordRegex)
        
        let validators = NSOrderedSet(array: [emptyValidator, regexValidator])
        return SPXCompoundDataValidator(validators: validators, validationType: SPXCompoundDataValidationType.ValidatorValidateAll)
    }
    
    class var usernameValidator: SPXCompoundDataValidator {
        let emptyValidator = SPXNonEmptyDataValidator()
        let regexValidator = SPXRegexDataValidator(expression: usernameRegex)
        
        let validators = NSOrderedSet(array: [emptyValidator, regexValidator])
        return SPXCompoundDataValidator(validators: validators, validationType: SPXCompoundDataValidationType.ValidatorValidateAll)
    }
}
