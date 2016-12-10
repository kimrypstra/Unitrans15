//
//  Settings.swift
//  Unitrans
//
//  Created by Kim Rypstra on 13/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit
import StoreKit

class Settings: UIView {
   
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var listContainer: List!
    @IBOutlet weak var listCenterX: NSLayoutConstraint!
    @IBOutlet weak var listWidth: NSLayoutConstraint!
    @IBOutlet weak var listTop: NSLayoutConstraint!
    @IBOutlet weak var fromLanguageLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var storeFrontView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var themeView: UIView!
    
    var listView: List?
    var storeManager = StoreManager()
    var pricesUpdated = false
    var developerMode: Bool?
    
    func getView() -> UIView {
        return Bundle.main.loadNibNamed("Settings", owner: nil, options: nil)?.first as! Settings
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        guard let url = URL(string: "https://www.facebook.com/Unitrans-a-Message-Translator-172949406445526") else {
            NSLog("Error: Icons URL error")
            return
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "GO_TO_SITE"), object: nil, userInfo: ["url":url]))

    }
    
    @IBAction func twitterButton(_ sender: Any) {
        guard let url = URL(string: "https://twitter.com/disorderware") else {
            NSLog("Error: Icons URL error")
            return
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "GO_TO_SITE"), object: nil, userInfo: ["url":url]))

    }
    
    @IBAction func webButton(_ sender: UIButton) {
        var URLString: String?
        switch sender.tag {
        case 0: URLString = "https://disordersoftware.com"
        case 1: URLString = "https://www.icons8.com"
        case 2: URLString = "http://translate.google.com"
        default: URLString = "https://disordersoftware.com"
        }
        
        guard let url = URL(string: URLString!) else {
            NSLog("Error: Icons URL error")
            return
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "GO_TO_SITE"), object: nil, userInfo: ["url":url]))
    }

    
    
    func loadDefaults(notification: Notification?) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RELOAD"), object: nil)
        versionLabel.text = "v\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)b\(Bundle.main.infoDictionary!["CFBundleVersion"]!)"
        let defaults = UserDefaults()
        
        if notification != nil {
            if let theme = notification?.userInfo?["theme"] as? Theme {
                self.themeLabel.text = theme.name
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "APPLY_THEME"), object: nil, userInfo: ["theme":theme])
            }
        }
        
        if let subscriptionStatus = defaults.value(forKey: "subscribed") as? Bool {
            if subscriptionStatus == true || developerMode == true {
                print("SUBSCRIBED!!!")
                // subscribed; remove storefront and add theme section
                stackView.removeArrangedSubview(storeFrontView)
                
                
            } else {
                // not subscribed, but was; add storefront and remove theme section
                print("NOT SUBSCRIBED!")
                stackView.removeArrangedSubview(themeView)
                
                
                if !pricesUpdated {
                    priceLabel.isHidden = true
                    storeFrontView.backgroundColor = UIColor.white
                    storeFrontView.layer.cornerRadius = 8
                    NotificationCenter.default.addObserver(self, selector: #selector(self.updateProductInfo), name: NSNotification.Name(rawValue: "didReceiveProductData"), object: nil)
                    storeFrontView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapStoreFront)))
                    storeManager.updateProductList()
                }
            }
            
        } else {
            // key is nil; user has never subscribed
            if !developerMode! {
                stackView.removeArrangedSubview(themeView)
                
                
                if !pricesUpdated {
                    priceLabel.isHidden = true
                    storeFrontView.backgroundColor = UIColor.white
                    storeFrontView.layer.cornerRadius = 8
                    NotificationCenter.default.addObserver(self, selector: #selector(self.updateProductInfo), name: NSNotification.Name(rawValue: "didReceiveProductData"), object: nil)
                    storeFrontView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapStoreFront)))
                    storeManager.updateProductList()
                }
            } else if developerMode! {
                print("SUBSCRIBED!!!")
                // subscribed; remove storefront and add theme section
                stackView.removeArrangedSubview(storeFrontView)

            }
            
        }
        
        
        
        

        if let defaultFromLanguage = defaults.value(forKey: "fromLanguage") as? String {
            // set the language label to the value
            let text = LanguageManager().nameFromCode(defaultFromLanguage, localized: true)
            print("From language: \(text!)")
            if text != nil {
                fromLanguageLabel.text = text
            } else {
                fromLanguageLabel.text = "Unknown: \(defaultFromLanguage)"
            }
        } else {
            // set the language label to automatic 
            print("No language set")
            fromLanguageLabel.text = NSLocalizedString("Automatic", comment: "A label which tells the user that the app will choose the 'from' language automatically")
        }
        
        if let theme = defaults.value(forKey: "theme") as? String {
            print("Theme: \(theme)")
            themeLabel.text = theme
        } else {
            print("No theme selected")
        }
        
        // find the other defaults!
    }
    
    func updateProductInfo(notification: Notification) {
        if let product = notification.userInfo?["product"] as? SKProduct {
            priceLabel.text = "\(product.priceLocale.currencySymbol!)\(product.price) per year"
            priceLabel.isHidden = false
            pricesUpdated = true 
        }
    }
    
    func didTapStoreFront() {
        storeManager.buyTheThing()
    }
    
    func removeList() {
        self.listCenterX.constant = 375
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.stackView.alpha = 1
            self.layoutIfNeeded()
        }, completion: { (success) in
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "START_SCROLL")))
            self.listView?.removeFromSuperview()
            self.listView = nil
        })
    }
    
    @IBAction func didTapTick(_ sender: UIButton) {
        print("Tapped tick")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "DISMISS_SETTINGS"), object: nil, userInfo: nil))
    }
    
    @IBAction func languageButton(_ sender: UIButton) {
        print("Hit button")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "STOP_SCROLL")))
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeList), name: NSNotification.Name(rawValue: "REMOVE_LANGUAGES"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadDefaults), name: NSNotification.Name(rawValue: "RELOAD"), object: nil)
        if listView == nil {
            listContainer.isHidden = false
            listView = Bundle.main.loadNibNamed("List", owner: self, options: nil)?.first as! List
            listView?.listViewHeight.constant = 488
            listView?.setup(mode: sender.restorationIdentifier!)
            if sender.restorationIdentifier == "themes" {
                listView?.selected = themeLabel.text
            } else {
                listView?.selected = fromLanguageLabel.text
            }
            // send in the data
            listView?.tableView.reloadData()
            listContainer.addSubview(listView!)
            
            listView?.translatesAutoresizingMaskIntoConstraints = false
            listContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":listView! as List]))
            
            listContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":listView! as List]))
            
            self.layoutIfNeeded()
            
            
            self.listCenterX.constant = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.stackView.alpha = 0
                self.layoutIfNeeded()
            }, completion: { (success) in
                
                // fill out the storefront
                
            })
            
        } 

    }

}
