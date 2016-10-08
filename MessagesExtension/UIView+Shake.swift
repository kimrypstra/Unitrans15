//
//  UIView+Shake.swift
//  UniversalTranslator
//
//  Created by Kim Rypstra on 27/08/2016.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-15.0, 15.0, -10.0, 8.0, -7.0, 5.0, -3.0, 3.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
