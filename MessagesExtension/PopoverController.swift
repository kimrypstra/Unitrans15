//
//  PopoverController.swift
//  coffeeNOW
//
//  Created by Kim Rypstra on 6/05/2016.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

public var poop = "Poop"

class PopoverController: UIViewController {

    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    var languageName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapStar(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            star1.setImage(UIImage(named: "starfilled"), for: .normal)
        case 2: print("2")
            star1.setImage(UIImage(named: "starfilled"), for: .normal)
            star2.setImage(UIImage(named: "starfilled"), for: .normal)
        case 3: print("3")
            star1.setImage(UIImage(named: "starfilled"), for: .normal)
            star2.setImage(UIImage(named: "starfilled"), for: .normal)
            star3.setImage(UIImage(named: "starfilled"), for: .normal)
        case 4: print("4")
            star1.setImage(UIImage(named: "starfilled"), for: .normal)
            star2.setImage(UIImage(named: "starfilled"), for: .normal)
            star3.setImage(UIImage(named: "starfilled"), for: .normal)
            star4.setImage(UIImage(named: "starfilled"), for: .normal)
        case 5: print("5")
            star1.setImage(UIImage(named: "starfilled"), for: .normal)
            star2.setImage(UIImage(named: "starfilled"), for: .normal)
            star3.setImage(UIImage(named: "starfilled"), for: .normal)
            star4.setImage(UIImage(named: "starfilled"), for: .normal)
            star5.setImage(UIImage(named: "starfilled"), for: .normal)
        default: break
        }
        
        /*
        if languageName != nil {
            let rating = GAIDictionaryBuilder.createEvent(withCategory: "Rating", action: "Microsoft", label: "\(languageName!)", value: sender.tag as NSNumber)
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(rating!.build() as [NSObject : AnyObject])
        } else {
            let rating = GAIDictionaryBuilder.createEvent(withCategory: "Rating", action: "Microsoft", label: "LANG_UNKNOWN", value: sender.tag as NSNumber)
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(rating!.build() as [NSObject : AnyObject])
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RATED"), object: nil)
        */
        
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
