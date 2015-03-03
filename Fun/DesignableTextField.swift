enum TextFieldValidation {
    case Valid, Invalid, Unknown
}
    
@IBDesignable class DesignableTextField: UITextField {

    @IBOutlet var nextTextField: UITextField?

    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            var padding = UIView(frame: CGRectMake(0, 0, leftPadding, 0))
            
            leftViewMode = UITextFieldViewMode.Always
            leftView = padding
        }
    }
    
    @IBInspectable var rightPadding: CGFloat = 0 {
        didSet {
            var padding = UIView(frame: CGRectMake(0, 0, 0, rightPadding))
            
            rightViewMode = UITextFieldViewMode.Always
            rightView = padding
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var validColor: UIColor = UIColor(red:0.25, green:0.68, blue:0.35, alpha:1)
    
    @IBInspectable var invalidColor: UIColor = UIColor(red:0.73, green:0.24, blue:0.17, alpha:1)
    
    @IBInspectable var defaultColor: UIColor = UIColor(red:0.59, green:0.65, blue:0.71, alpha:1)
    
    var validated: TextFieldValidation = .Unknown {
        didSet {
            switch (validated) {
            case .Valid:
                self.borderColor = validColor
            case .Invalid:
                self.borderColor = invalidColor
            case .Unknown:
                self.borderColor = defaultColor
            }
        }
    }

}