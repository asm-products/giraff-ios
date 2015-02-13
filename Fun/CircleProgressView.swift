/*
Copyright (c) 2013 Cardinal Solutions

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit

@IBDesignable class CircleProgressView: UIView {
  
  internal struct Constants {
    let circleDegress = 360.0
    let minimumValue = 0.000001
    let maximumValue = 0.999999
    let ninetyDegrees = 90.0
    let twoSeventyDegrees = 270.0
    var contentView:UIView = UIView()
  }
  
  let constants = Constants()
  
  @IBInspectable var progress: Double = 0.000001 {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var clockwise: Bool = true {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var trackWidth: CGFloat = 10 {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var trackImage: UIImage? {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var trackBackgroundColor: UIColor = UIColor.grayColor() {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var trackFillColor: UIColor = UIColor.blueColor() {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var trackBorderColor:UIColor = UIColor.grayColor() {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var trackBorderWidth: CGFloat = 0 {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var centerFillColor: UIColor = UIColor.whiteColor() {
    didSet { setNeedsDisplay() }
  }
  
  @IBInspectable var contentView: UIView {
    return self.constants.contentView
  }
  
  required override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(contentView)
    contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.addSubview(contentView)
    contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
  }
  
  override func drawRect(rect: CGRect) {
    
    super.drawRect(rect)
    
    let innerRect = CGRectInset(rect, trackBorderWidth, trackBorderWidth)
    
    progress = (progress/1.0) == 0.0 ? constants.minimumValue : progress
    progress = (progress/1.0) == 1.0 ? constants.maximumValue : progress
    progress = clockwise ? (-constants.twoSeventyDegrees + ((1.0 - progress) * constants.circleDegress)) : (constants.ninetyDegrees - ((1.0 - progress) * constants.circleDegress))
    
    let context = UIGraphicsGetCurrentContext()
    
    // background Drawing
    trackBackgroundColor.setFill()
    let circlePath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect)))
    circlePath.fill();
    
    if trackBorderWidth > 0 {
      circlePath.lineWidth = trackBorderWidth
      trackBorderColor.setStroke()
      circlePath.stroke()
    }
    
    // progress Drawing
    let progressPath = UIBezierPath()
    let progressRect: CGRect = CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect))
    let center = CGPointMake(progressRect.midX, progressRect.midY)
    let radius = progressRect.width / 2.0
    let startAngle:CGFloat = clockwise ? CGFloat(-progress * M_PI / 180.0) : CGFloat(constants.twoSeventyDegrees * M_PI / 180)
    let endAngle:CGFloat = clockwise ? CGFloat(constants.twoSeventyDegrees * M_PI / 180) : CGFloat(-progress * M_PI / 180.0)
    
    progressPath.addArcWithCenter(center, radius:radius, startAngle:startAngle, endAngle:endAngle, clockwise:!clockwise)
    progressPath.addLineToPoint(CGPointMake(progressRect.midX, progressRect.midY))
    progressPath.closePath()
    
    CGContextSaveGState(context)
    
    progressPath.addClip()
    
    if trackImage != nil {
      trackImage!.drawInRect(innerRect)
    } else {
      trackFillColor.setFill()
      circlePath.fill()
    }
    
    CGContextRestoreGState(context)
    
    // center Drawing
    let centerPath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX + trackWidth, innerRect.minY + trackWidth, CGRectGetWidth(innerRect) - (2 * trackWidth), CGRectGetHeight(innerRect) - (2 * trackWidth)))
    centerFillColor.setFill()
    centerPath.fill()
    
    let layer = CAShapeLayer()
    layer.path = centerPath.CGPath
    contentView.layer.mask = layer
    
  }
  
}