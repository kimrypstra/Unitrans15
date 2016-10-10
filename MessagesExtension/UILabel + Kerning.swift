//
//  UILabel + Kerning.swift
//  Unitrans
//
//  Created by Kim Rypstra on 10/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    func addTextSpacing(spacing: CGFloat){
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: self.text!.characters.count))
        self.attributedText = attributedString
    }
}
