//
//  Indicators.swift
//  Unitrans
//
//  Created by Kim Rypstra on 12/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class Indicators: UIView {
    
    @IBOutlet weak var outerChevron: UIImageView!
    @IBOutlet weak var middleChevron: UIImageView!
    @IBOutlet weak var innerChevron: UIImageView!

    @IBOutlet weak var middleToOuter: NSLayoutConstraint!
    @IBOutlet weak var innerToMiddle: NSLayoutConstraint!
    
    var timer: Timer?
    
    let spacing: CGFloat = -37 //Lower is closer since they overlap
    
    func getView() -> UIView {
        return Bundle.main.loadNibNamed("Indicators", owner: nil, options: nil)?.first as! UIView
    }
    
    func setupChevrons() {
        middleToOuter.constant = spacing
        innerToMiddle.constant = spacing
        
        outerChevron.alpha = 0.2
        middleChevron.alpha = 0.35
        innerChevron.alpha = 0.5
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.pulse), userInfo: nil, repeats: true)
    }


    func pulse() {
        innerChevron.alpha = 1
        UIView.animate(withDuration: 0.8, animations: {() -> Void in
            self.innerChevron.alpha = 0.5
        })
        let _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {(timer) -> Void in
            self.middleChevron.alpha = 0.85
            UIView.animate(withDuration: 0.8, animations: {() -> Void in
                self.middleChevron.alpha = 0.35
            })
        })
        let _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {(timer) -> Void in
            self.outerChevron.alpha = 0.7
            UIView.animate(withDuration: 0.8, animations: {() -> Void in
                self.outerChevron.alpha = 0.2
            })
        })
    }
}
