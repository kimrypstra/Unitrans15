//
//  DSPickerView.swift
//  Unitrans
//
//  Created by Kim Rypstra on 9/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class DSPickerIndicators: UIView {

    let baseChevron = UIImage(named: "chevron")
    let centre = CGPoint()
    
    @IBInspectable var gapBetweenChevronSets: CGFloat = 58
    @IBInspectable var gapBetweenChevrons: CGFloat = 5
    
    func setUpChevrons() {
        center = self.centre
        for number in 0...2 {
            let iteration = CGFloat(number)
            let chevron = UIImageView(image: baseChevron)
            chevron.frame.size = CGSize(width: 50, height: 50)
            chevron.center = CGPoint(x: center.x, y: centre.y - (gapBetweenChevronSets / 2 - (gapBetweenChevrons * iteration)))
            self.addSubview(chevron)
        }
        
        for number in 0...2 {
            let iteration = CGFloat(number)
            let chevron = UIImageView(image: baseChevron)
            chevron.frame.size = CGSize(width: 50, height: 50)
            chevron.center = CGPoint(x: center.x, y: centre.y - (gapBetweenChevronSets / 2 + (gapBetweenChevrons * iteration)))
            chevron.transform.rotated(by: CGFloat(M_PI))
            self.addSubview(chevron)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
