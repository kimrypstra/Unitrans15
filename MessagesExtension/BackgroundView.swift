//
//  BackgroundView.swift
//  
//
//  Created by Kim Rypstra on 8/10/16.
//
//

import UIKit

@IBDesignable class BackgroundView: UIView {

    @IBInspectable var topColor: UIColor!
    @IBInspectable var bottomColor: UIColor!
    @IBInspectable var top: CGFloat = 0.0
    @IBInspectable var bottom: CGFloat = 1.0
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let colors = [topColor.cgColor, bottomColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations = [top, bottom]
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations) {
            let start = CGPoint.zero
            let end = CGPoint(x: 0, y: self.bounds.height)
            context?.drawLinearGradient(gradient, start: start, end: end, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        } else {
            NSLog("Error making CGGradient")
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 

}
