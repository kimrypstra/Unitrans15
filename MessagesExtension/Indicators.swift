//
//  Indicators.swift
//  Unitrans
//
//  Created by Kim Rypstra on 12/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

@IBDesignable

class Indicators: UIView {
    
    @IBOutlet weak var label: UILabel!
    
    
    func getView() -> UIView {
        return Bundle.main.loadNibNamed("Indicators", owner: nil, options: nil)?.first as! UIView
        
    }

    func setText() {
        if label != nil {
            label.text = "Hello, there"
        } else {
            print("Label is nil?")
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
