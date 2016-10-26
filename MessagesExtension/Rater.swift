//
//  Rater.swift
//  Unitrans
//
//  Created by Kim Rypstra on 22/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class Rater: UIView {

    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!

    func getView() -> UIView {
        
        return Bundle.main.loadNibNamed("Rater", owner: nil, options: nil)?.first as! Rater
    }
    
    @IBAction func didTapStar(_ sender: UIButton) {
        print("Tapped")
        switch sender.tag {
        case 1:
        print("1")
        star1.setImage(UIImage(named: "starfilled"), for: .normal)
        case 2:
        print("2")
        star1.setImage(UIImage(named: "starfilled"), for: .normal)
        star2.setImage(UIImage(named: "starfilled"), for: .normal)
        case 3:
        print("3")
        star1.setImage(UIImage(named: "starfilled"), for: .normal)
        star2.setImage(UIImage(named: "starfilled"), for: .normal)
        star3.setImage(UIImage(named: "starfilled"), for: .normal)
        case 4:
        print("4")
        star1.setImage(UIImage(named: "starfilled"), for: .normal)
        star2.setImage(UIImage(named: "starfilled"), for: .normal)
        star3.setImage(UIImage(named: "starfilled"), for: .normal)
        star4.setImage(UIImage(named: "starfilled"), for: .normal)
        case 5:
        print("5")
        star1.setImage(UIImage(named: "starfilled"), for: .normal)
        star2.setImage(UIImage(named: "starfilled"), for: .normal)
        star3.setImage(UIImage(named: "starfilled"), for: .normal)
        star4.setImage(UIImage(named: "starfilled"), for: .normal)
        star5.setImage(UIImage(named: "starfilled"), for: .normal)
        default: break
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RATED"), object: nil, userInfo: ["rating" : sender.tag]))
    }
    
    
    func presentStars() {
        print("Height: \(self.frame.height), yPos: \(star1.center.y)")
        let timeSep = 0.05
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 1, repeats: false, block: {(Timer) -> Void in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //self.star5.center.y = centerHeight
                self.star5.alpha = 1
                self.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 2, repeats: false, block: {(Timer) -> Void in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //self.star4.center.y = centerHeight
                self.star4.alpha = 1
                self.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 3, repeats: false, block: {(Timer) -> Void in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //self.star3.center.y = centerHeight
                self.star3.alpha = 1
                self.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 4, repeats: false, block: {(Timer) -> Void in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //self.star2.center.y = centerHeight
                self.star2.alpha = 1
                self.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 5, repeats: false, block: {(Timer) -> Void in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //self.star1.center.y = centerHeight
                self.star1.alpha = 1
                self.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        

    }
    

}
