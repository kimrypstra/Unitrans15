//
//  ExpandedViewController.swift
//  Unitrans
//
//  Created by Kim Rypstra on 14/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit
import Messages

class ExpandedViewController: MSMessagesAppViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate {

    
    @IBOutlet weak var settingsContainer: Settings!
    @IBOutlet weak var settingsContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var raterContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var backgroundVertical: NSLayoutConstraint!
    @IBOutlet weak var bubble: UIImageView!
    @IBOutlet weak var background: BackgroundView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var buttonStackViewSep: NSLayoutConstraint!
    @IBOutlet weak var buttonStackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet weak var swapButtonVert: NSLayoutConstraint!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewVerticalOffset: NSLayoutConstraint!
    @IBOutlet weak var textViewToBubbleTop: NSLayoutConstraint!
    @IBOutlet weak var textViewToBubbleBottom: NSLayoutConstraint!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var raterContainer: Rater!
    
    
    //xibs
    var raterView: Rater?
    var settingsView: Settings?
    
    //Managers
    let messageManager = MessageManager()
    
    //TextView
    var textViewIsScrollEnabled = false
    var textViewHeightConstraint: NSLayoutConstraint? = nil
    var keyboardHeight: CGFloat?
    let topBarHeight: CGFloat = 85
    var remainingHeight: CGFloat? = nil
    var pulseTimer: Timer?
    
    //Magic Numbers
    var desiredVerticalOffsetForTextView: CGFloat?
    var conversationIdentifier: String?
    let separationGap: CGFloat = 20

    //Enums & Structs
    enum Mode {
        case Compose(String, Bool)
        case View(String)
        case Reply(String, Bool)
        
        func get() -> (String, Bool?) {
            switch self {
            case .Compose(let languageCode, let translator):
                return (languageCode, translator)
            case .View(let url):
                return (url, nil)
            case .Reply(let languageCode, let translator):
                return (languageCode, translator)
            }
        }
    }
    var composerMode: Mode!
    
    struct MessageData {
        let translatedText: String
        let originalText: String
        let translatedLanguage: String
        let originalLanguage: String
        var displayingOriginal = false
    }
    var message: MessageData!
    
    /*--------------------------------------*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.errorHandler), name: NSNotification.Name(rawValue: "ERROR"), object: nil)
        setUpInterface()
        
        
        /*
        let marker = UIView(frame: CGRect(x: self.view.frame.width / 2, y: 0, width: 1, height: self.view.frame.height))
        marker.backgroundColor = UIColor.red
        self.view.addSubview(marker)
        */
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Here we'll check the composer mode
        
        /*
        goButton.layer.borderColor = UIColor.red.cgColor
        goButton.layer.borderWidth = 1
        rateButton.layer.borderColor = UIColor.red.cgColor
        rateButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = UIColor.red.cgColor
        settingsButton.layer.borderWidth = 1
        */
        
        switch composerMode! {
        case .View:
            print("View mode")
            if let query = URL(string: composerMode.get().0)?.query?.removingPercentEncoding?.removingPercentEncoding {
                let sep = query.components(separatedBy: "&")
                var text = sep[0] as String
                var from = sep[1] as String
                var to = sep[2] as String
                var original = sep[3] as String
                print("Pre purge text: \(text)")
                text = text.replacingOccurrences(of: "text=", with: "")
                original = original.replacingOccurrences(of: "original=", with: "")
                to = to.replacingOccurrences(of: "to=", with: "")
                from = from.replacingOccurrences(of: "from=", with: "")
                message = MessageData(
                    translatedText: text,
                    originalText: original,
                    translatedLanguage: to,
                    originalLanguage: from,
                    displayingOriginal: false
                )
                
                // Set up the textView and other UI
                desiredVerticalOffsetForTextView = 80
                buttonStackViewWidth.constant = (goButton.frame.width * 3) + (separationGap * 2)
                textView.text = text
            }
        case .Compose:
            print("Compose mode")
            // get rid of swap button, rate button, and shift the two remaining buttons over by shifting the goButton (which the other two are tied to) to the right by half the separation of goButton and settingsButton
            textView.text = ""
            rateButton.isHidden = true
            swapButton.isHidden = true
            desiredVerticalOffsetForTextView = 25
            buttonStackViewWidth.constant = (goButton.frame.width * 2) + (separationGap * 1)
            print("Language code: \(composerMode.get())")
            

        case .Reply:
            fatalError("Error - should not ever be in reply mode unless goButton is hit within view mode")
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // animate the UI in
        let timeSep = 0.1
        let buttonToBubbleSep: CGFloat = 50
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 1, repeats: false, block: {(Timer) -> Void in
            self.swapButtonVert.constant = 20
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.swapButton.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 2, repeats: false, block: {(Timer) -> Void in
            self.textViewVerticalOffset.constant = self.desiredVerticalOffsetForTextView!
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.bubble.alpha = 1
                self.textView.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 3, repeats: false, block: {(Timer) -> Void in
            self.buttonStackViewSep.constant = buttonToBubbleSep
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.rateButton.alpha = 0.58
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 4, repeats: false, block: {(Timer) -> Void in
            let center = self.goButton.center.y
            self.goButton.center.y += 20
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.goButton.center.y = center
                self.goButton.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                //blah
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: timeSep * 5, repeats: false, block: {(Timer) -> Void in
            let center = self.settingsButton.center.y
            self.settingsButton.center.y += 40
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.settingsButton.center.y = center
                self.settingsButton.alpha = 0.58
                self.view.layoutIfNeeded()
            }, completion: { (success) in

                switch self.composerMode! {
                case .Compose: self.textView.becomeFirstResponder()
                default: break
                }
                
            })
        })
        
    }

    /*
    willTransition
    shove the UI up out of the way, the same way the language picker goes away 
     then transition
    - stackView 
     - textView
     - imageView
     
     didTransition
     bring the picker UI back down in reverse, back to what they were 
 */
    
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        
        if presentationStyle == .compact {

                self.swapButtonVert.constant = -100
                self.textViewVerticalOffset.constant = -100
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.swapButton.alpha = 0
                    self.bubble.alpha = 0
                    self.textView.alpha = 0
                    self.view.layoutIfNeeded()
                }, completion: { (success) in
                    //blah
                })


            

        }
        

    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // do some stuff 
    }
    
    func handleKeyboard(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? NSValue else {
            fatalError("Keyboard has no frame")
        }
        self.keyboardHeight = keyboardFrame.cgRectValue.height
        let screenHeight = UIScreen.main.bounds.height
        let interfaceHeight = textViewVerticalOffset.constant + buttonStackViewSep.constant + goButton.frame.height + 20 /*bubble padding*/ + 50 /*lower padding and keyboard accessory*/
        self.remainingHeight = screenHeight - keyboardHeight! - interfaceHeight
    }
    
    func setUpInterface() {
        // Set up the UI colours etc.
        bubble.image = bubble.image?.withRenderingMode(.alwaysTemplate)
        bubble.tintColor = UIColor.white.withAlphaComponent(0.4)
        bubble.alpha = 0
        
        rateButton.alpha = 0
        goButton.alpha = 0
        settingsButton.alpha = 0
        swapButton.alpha = 0
        
        textView.alpha = 0
        textView.tintColor = UIColor.white
        textViewToBubbleTop.constant = textView.font!.lineHeight / 2
        textViewToBubbleBottom.constant = (textView.font!.lineHeight / 2) * -1
   
    }
    
    func toggleSpinner() {
        if spinner.isAnimating {
            spinner.stopAnimating()
            UIView.animate(withDuration: 0.5, animations: {
                self.blur.alpha = 0
            })
        } else {
            spinner.startAnimating()
            UIView.animate(withDuration: 0.5, animations: {
                self.blur.alpha = 1
            })
        }
    }
    
    func errorHandler(notification: Notification) {
        print("An error has occurred")
        if let error = notification.userInfo?["error"] as? DSError {
            let alert = UIAlertController(title: "Error", message: error.domain, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                if self.spinner.isAnimating {
                    self.toggleSpinner()
                }
                if self.goButton.isEnabled == false {
                    self.goButton.setImage(UIImage(named: "rightArrow"), for: .normal)
                    self.goButton.isEnabled = true
                }
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            // Send the error to the analytics suite
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        var maxHeight: CGFloat {
            if remainingHeight != nil {
                return remainingHeight!
            } else {
                return 137
            }
        }
        
        let contentHeight = textView.contentSize.height
        var shouldAnimate = true
        
        if contentHeight + textView.font!.lineHeight > maxHeight && textViewIsScrollEnabled == false {
            // Too big!
            self.textView.isScrollEnabled = true
            print("Scrolling. Content: \(contentHeight), Max: \(maxHeight)")
            textViewHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: maxHeight)
            textView.addConstraint(textViewHeightConstraint!)
            textViewIsScrollEnabled = true
        } else if textViewIsScrollEnabled == true && contentHeight + textView.font!.lineHeight < maxHeight {
            // Not too big!
            print("Not Scrolling. Content: \(contentHeight), Max: \(maxHeight)")
            if textViewHeightConstraint != nil {
                self.textView.isScrollEnabled = false
                textView.removeConstraint(textViewHeightConstraint!)
                textViewHeightConstraint = nil
                self.textView.text = self.textView.text + " "
                self.textView.text.remove(at: self.textView.text.index(before: self.textView.text.endIndex))
                textViewIsScrollEnabled = false
                shouldAnimate = false
            }
  
        }
        
        if shouldAnimate {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                // blah
            })
        }
        

    }

    @IBAction func didTapSwap(_ sender: UIButton) {
        if message.displayingOriginal {
            UIView.transition(with: textView, duration: 0.35, options: [.transitionCrossDissolve], animations: {
                self.textView.text = self.message.translatedText
            }, completion: nil)
            message.displayingOriginal = false
        } else {
            UIView.transition(with: textView, duration: 0.35, options: [.transitionCrossDissolve], animations: {
                self.textView.text = self.message.originalText
            }, completion: nil)
            message.displayingOriginal = true
        }
    }
    
    @IBAction func didTapGo(_ sender: UIButton) {
        switch composerMode! {
        case .Compose:
            goButton.setImage(UIImage(named: "blankButton"), for: .normal)
            goButton.isEnabled = false
            toggleSpinner()
            setDefaultsForConversation(toLanguage: composerMode.get().0)
            textView.resignFirstResponder()
            messageManager.requestTranslation(textToTranslate: textView.text, toCode: composerMode.get().0, fromCode: "en", google: composerMode.get().1!)
        case .View:
            // Change the UI
            
            UIView.animate(withDuration: 0.2, animations: { 
                self.swapButton.alpha = 0
                self.rateButton.alpha = 0
                
            }, completion: { (success) in
                self.buttonStackViewWidth.constant = (self.goButton.frame.width * 2) + (self.separationGap * 2)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.rateButton.isHidden = true
                    self.view.layoutIfNeeded()
                }, completion: { (success) in
                    // blah
                })
            })

            desiredVerticalOffsetForTextView = 25
            textViewVerticalOffset.constant = desiredVerticalOffsetForTextView! + 10
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            // Change composer to .Reply, setting the 'to' language to the original language
            
            self.composerMode = .Reply(message.originalLanguage, LanguageManager().checkIfMicrosoft(code: message.originalLanguage))
            
            // Present keyboard etc. 
            self.textView.text = ""
            self.textView.becomeFirstResponder()
        case .Reply:
            toggleSpinner()
            setDefaultsForConversation(toLanguage: composerMode.get().0)
            textView.resignFirstResponder()
            print("Looks like google bool is: \(composerMode.get().1!)")
            messageManager.requestTranslation(textToTranslate: textView.text, toCode: composerMode.get().0, fromCode: message.translatedLanguage, google: composerMode.get().1!)
        }
    }
    
    @IBAction func didTapRate(_ sender: UIButton) {
        if raterView == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didTapRate), name: NSNotification.Name(rawValue: "RATED"), object: nil)
            raterView?.frame.size.width = self.view.frame.width
            raterView = raterContainer.getView() as? Rater
            
            raterContainer.addSubview(raterView!)
            
            if backgroundVertical.constant == topBarHeight {
                backgroundVertical.constant = topBarHeight + raterContainerHeight.constant
            } else {
                backgroundVertical.constant = topBarHeight
            }

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                
            })
            self.raterView?.presentStars()
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RATED"), object: nil)
            if backgroundVertical.constant != topBarHeight {
                backgroundVertical.constant = topBarHeight
            } else {
                backgroundVertical.constant = topBarHeight + raterContainerHeight.constant
            }
            
            
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                self.raterView?.removeFromSuperview()
                self.raterView = nil
            })
            
            self.rateButton.isEnabled = false 
            
        }
    }
    
    func stopScroll() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "STOP_SCROLL"), object: nil)
        settingsButton.isEnabled = true
        goButton.isEnabled = true
        swapButton.isEnabled = true
        rateButton.isEnabled = true
        
    }
    
    func startScroll() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "START_SCROLL"), object: nil)
        settingsButton.isEnabled = true
        goButton.isEnabled = true
        swapButton.isEnabled = true
        rateButton.isEnabled = true
        
    }
    
    func dismissSettings() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DISMISS_SETTINGS"), object: nil)
        if backgroundVertical.constant != topBarHeight {
            backgroundVertical.constant = topBarHeight
        } else {
            backgroundVertical.constant = topBarHeight + settingsContainerHeight.constant
        }
        
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (success) in
            self.settingsView?.removeFromSuperview()
            self.settingsView = nil
        })

    }
    
    // listView is aligned to the top of the scrollView so if you scroll down and present the list it is out of place 
    // 
    
    
    
    @IBAction func didTapSettings(_ sender: UIButton) {
        settingsButton.isEnabled = false
        goButton.isEnabled = false
        swapButton.isEnabled = false
        rateButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopScroll), name: NSNotification.Name(rawValue: "STOP_SCROLL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startScroll), name: NSNotification.Name(rawValue: "START_SCROLL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissSettings), name: NSNotification.Name(rawValue: "DISMISS_SETTINGS"), object: nil)
        if settingsView == nil {
            textView.resignFirstResponder()
            settingsView = Bundle.main.loadNibNamed("Settings", owner: self, options: nil)?.first as! Settings
            settingsContainer.addSubview(settingsView!)
            settingsView?.loadDefaults()
            settingsView?.listContainer.isHidden = true 
            settingsView?.translatesAutoresizingMaskIntoConstraints = false
            settingsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":settingsView! as Settings]))

            settingsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":settingsView! as Settings]))
            
            self.view.layoutIfNeeded()
            if backgroundVertical.constant == topBarHeight {
                backgroundVertical.constant = topBarHeight + settingsContainerHeight.constant
            } else {
                backgroundVertical.constant = topBarHeight
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                // fill out the storefront 
                
            })
            
        } else {
            dismissSettings()
//            if backgroundVertical.constant != topBarHeight {
//                backgroundVertical.constant = topBarHeight
//            } else {
//                backgroundVertical.constant = topBarHeight + settingsContainerHeight.constant
//            }
//            
//            
//            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
//                self.view.layoutIfNeeded()
//            }, completion: { (success) in
//                self.settingsView?.removeFromSuperview()
//                self.settingsView = nil
//            })
//            
            
        }
    }

    
    
    func setDefaultsForConversation(toLanguage: String) {
        var conversationDefaults = [String: String]()
        conversationDefaults["toLanguage"] = LanguageManager().nameFromCode(toLanguage, localized: true)
        let defaults = UserDefaults()
        if conversationIdentifier != nil {
            defaults.setValue(conversationDefaults, forKey: conversationIdentifier!)
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}