//
//  ExpandedViewController.swift
//  Unitrans
//
//  Created by Kim Rypstra on 14/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit
import Messages
import WebKit
import SafariServices
import AudioToolbox

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
    var topBarHeight: CGFloat = 85
    var remainingHeight: CGFloat? = nil
    var pulseTimer: Timer?
    
    //Stuff
    var desiredVerticalOffsetForTextView: CGFloat?
    var conversationIdentifier: String?
    let separationGap: CGFloat = 20
    var developerMode: Bool?
    var theme: Theme?
    var subscribed: Bool!
    var shouldPresentSettings = false
    var maxLength = 320
    var subscriptionPromptPresented = false
    var savedText: String?
    
    //Enums & Structs
    enum Mode {
        case Compose(String, String)
        case View(String)
        case Reply(String, String)
        
        func get() -> (String, String?) {
            switch self {
            case .Compose(let languageCode, let fromLanguage):
                return (languageCode, fromLanguage)
            case .View(let url):
                return (url, nil)
            case .Reply(let languageCode, let fromLanguage):
                return (languageCode, fromLanguage)
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
    
    var settingsIsPresented = false
    var respondToNotificationCalled = false
    
    /*--------------------------------------*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment "WILL_RESIGN" notification to start working on state saving. Commented out because I don't want unexpected behaviour if the call suddenly starts to work for some reason. 
        //NotificationCenter.default.addObserver(self, selector: #selector(self.willResign), name: .init(rawValue: "WILL_RESIGN"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.errorHandler), name: NSNotification.Name(rawValue: "ERROR"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToWeb), name: NSNotification.Name(rawValue: "GO_TO_SITE"), object: nil)
        setUpInterface()
    
        self.view.frame.origin.y += 65
        print("Screen height: \(UIScreen.main.bounds.height)")
        if UIScreen.main.bounds.height < 667  {
            topBarHeight = 65
        }

        print("Vertical height: \(backgroundVertical.constant)")
        //background.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
    }
    
    func goToWeb(sender: Notification) {
        if let mail = sender.userInfo?["mail"] as? Bool {
            if let url = sender.userInfo?["url"] as? URL {
                NSLog("**** Mail...")
                self.extensionContext?.open(url, completionHandler: nil)
                
            }
        } else {
            if let url = sender.userInfo?["url"] as? URL {
                let safari = SFSafariViewController(url: url)
                self.present(safari, animated: true, completion: nil)
            }
        }
    }
    
    func willResign() {
        // This currently doesn't work
        if composerMode != nil && textView.text != nil && textView.text != "" {
            print("***** WILL RESIGN")
            switch composerMode! {
            case .Reply, .Compose: setDefaultsForConversation(toLanguage: composerMode.get().0, text: textView.text)
            default: break
            }
        }
    }
    
    func respondToNotification(notification: Notification) {
        // This is called when a theme is applied - we're responding to the notification that contains the theme information
        if !respondToNotificationCalled {
            respondToNotificationCalled = true
            if let theme = notification.userInfo?["theme"] as? Theme {
                applyTheme(theme: theme, notification: nil)
            } else {
                NSLog("**** No theme at respondToNotification")
            }
            if subscribed == false && notification.userInfo!["subscribed"] as? Bool == true {
                subscribed = true
                maxLength = 1000
            }
        }
    }
    
    func applyTheme(theme: Theme?, notification: Notification?) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "APPLY_THEME"), object: nil)
        if theme != nil {
            self.theme = theme
        } else if notification != nil {
            if let themeFromNotification = notification?.userInfo?["theme"] as? Theme? {
                self.theme = themeFromNotification
            }
        }
        
        NSLog("**** Applying theme: \(theme?.name!)")
        background.topColor = self.theme?.topColour
        background.bottomColor = self.theme?.bottomColour
        
        textView.textColor = self.theme?.textColour
        
        if self.theme?.isRichTheme == true {
            // change the images to suit the detailed theme
            bubble.image = UIImage(named: "\(self.theme!.imagePrefix!)Bubble")?.withRenderingMode(.alwaysOriginal)
            goButton.setImage(UIImage(named: "\(self.theme!.imagePrefix!)GoButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
            rateButton.setImage(UIImage(named: "\(self.theme!.imagePrefix!)RateButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
            settingsButton.setImage(UIImage(named: "\(self.theme!.imagePrefix!)SettingsButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
            swapButton.setImage(UIImage(named: "\(self.theme!.imagePrefix!)SwapButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            bubble.image = UIImage(named: "bubble")?.withRenderingMode(.alwaysTemplate)
            goButton.setImage(UIImage(named: "rightArrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
            rateButton.setImage(UIImage(named: "rateButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
            settingsButton.setImage(UIImage(named: "settingsButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
            swapButton.setImage(UIImage(named: "swapButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
            
            bubble.tintColor = self.theme?.bubbleColour
            goButton.imageView?.tintColor = self.theme?.buttonColour
            rateButton.imageView?.tintColor = self.theme?.buttonColour
            settingsButton.imageView?.tintColor = self.theme?.buttonColour
            swapButton.imageView?.tintColor = self.theme?.buttonColour
        }
        
        if self.theme?.darkKeyboard == true {
            textView.keyboardAppearance = .dark
        } else {
            textView.keyboardAppearance = .default
        }
        background.setNeedsDisplay()
        respondToNotificationCalled = false 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // apply the theme 
        applyTheme(theme: theme!, notification: nil)
        
        if subscribed! {
            maxLength = 1000
        }
        
        //Here we'll check the composer mode
        switch composerMode! {
        case .View:
            NSLog("**** View mode")
            if let query = URL(string: composerMode.get().0)?.query?.removingPercentEncoding?.removingPercentEncoding {
                let sep = query.components(separatedBy: "&&")
                var text = String(htmlEncodedString: sep[0] as String)
                var from = sep[1] as String
                var to = sep[2] as String
                var original = sep[3] as String
                NSLog("**** Pre purge text: \(text)")
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
            NSLog("**** Compose mode")
            // get rid of swap button, rate button, and shift the two remaining buttons over by shifting the goButton (which the other two are tied to) to the right by half the separation of goButton and settingsButton
            if savedText != nil {
                textView.text = savedText
            } else {
                textView.text = ""
            }
            
            rateButton.isHidden = true
            swapButton.isHidden = true
            desiredVerticalOffsetForTextView = 25
            buttonStackViewWidth.constant = (goButton.frame.width * 2) + (separationGap * 1)
            NSLog("**** Language code: \(composerMode.get())")
            

        case .Reply:
            fatalError("Error - should not ever be in reply mode unless goButton is hit within view mode")
        }
        

    }
    
    override func viewDidLayoutSubviews() {
        if UIScreen.main.bounds.height < 667 && !settingsIsPresented {
            backgroundVertical.constant = 65
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Background vertical \(backgroundVertical.constant)")
        if shouldPresentSettings {
            didTapSettings(nil)
        } else {
            
            switch composerMode! {
            case .View: self.textView.isEditable = false
            default: self.textView.isEditable = true
            }
        
        // animate the UI in
        let timeSep = 0.1
        let buttonToBubbleSep: CGFloat = 50
        if !settingsIsPresented {
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
                    case .Compose:
                        self.textView.becomeFirstResponder()
                    default:
                        break
                    }
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.prepareForTransition), name: NSNotification.Name(rawValue: "GOING_TO_COMPACT"), object: nil)
                    
                })
            })
        }
        }
    }

    func prepareForTransition() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        })
        self.dismiss(animated: false, completion: nil)
    }
    
    func handleKeyboard(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? NSValue else {
            fatalError("Keyboard has no frame")
        }
        self.keyboardHeight = keyboardFrame.cgRectValue.height
        let screenHeight = UIScreen.main.bounds.height
        let interfaceHeight = textViewVerticalOffset.constant + buttonStackViewSep.constant + goButton.frame.height + 20 /*bubble padding*/ + 120 /*lower padding and keyboard accessory -- *** CHANGE THIS NUMBER TO CHANGE THE MAX TEXT VIEW HEIGHT FOR SOME REASON *** */
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
    
//    func presentMessage() {
//        let alert = UIAlertController(title: NSLocalizedString("Thank you!", comment: "Thanking the user for purchasing"), message: nil, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "A button to say 'Ok, dismiss the alert'"), style: .default, handler: nil)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PRESENT_MESSAGE"), object: nil)
//    }
    
    func errorHandler(notification: Notification) {
        NSLog("**** An error has occurred")
        if let error = notification.userInfo?["error"] as? DSError {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Presented when an error has occured"), message: "\(error.domain), Code: \(error.code)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "A button to say 'Ok, dismiss the alert'"), style: .default, handler: { (action) in
                if self.spinner.isAnimating {
                    self.toggleSpinner()
                }
                if self.goButton.isEnabled == false {
                    NSLog("**** Setting image...")
                    if self.theme?.isRichTheme == true {
                        self.goButton.setImage(UIImage(named: "\(self.theme!.imagePrefix!)GoButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    } else {
                        self.goButton.setImage(UIImage(named: "rightArrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    }
                    self.goButton.isEnabled = true
                }
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            // Send the error to the analytics suite
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var shouldReturn = true
        if textView.text.characters.count + (text.characters.count - range.length) <= maxLength {
            return true
        } else {
            textView.shake()
            bubble.shake()
            AudioServicesPlaySystemSound(1521)
            // present subscription dialog 
            if !subscriptionPromptPresented && !subscribed {
                let alert = UIAlertController(title: "Subscribe!", message: "Subscribe to send messages up to 1000 characters", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                let subAction = UIAlertAction(title: "Subscribe", style: .default, handler: { (action) in
                    self.didTapSettings(nil)
                })
                alert.addAction(okAction)
                alert.addAction(subAction)
                self.subscriptionPromptPresented = true 
                self.present(alert, animated: true, completion: nil)
            }
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Seriously just don't mess with this
        var maxHeight: CGFloat {
            if remainingHeight != nil {
                return remainingHeight!
            } else {
                return 117
            }
        }
        
        let contentHeight = textView.contentSize.height
        var shouldAnimate = true
        print(contentHeight)
        if contentHeight + textView.font!.lineHeight > maxHeight && textViewIsScrollEnabled == false {
            // Too big!
            self.textView.isScrollEnabled = true
            NSLog("**** Scrolling. Content: \(contentHeight), Max: \(maxHeight)")
            textViewHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: maxHeight)
            textView.addConstraint(textViewHeightConstraint!)
            textViewIsScrollEnabled = true
        } else if textViewIsScrollEnabled == true && contentHeight + textView.font!.lineHeight < maxHeight {
            // Not too big!
            NSLog("**** Not Scrolling. Content: \(contentHeight), Max: \(maxHeight)")
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
            if textView.text.characters.count > 0 {
                goButton.setImage(UIImage(named: "blankButton"), for: .normal)
                goButton.isEnabled = false
                toggleSpinner()
                setDefaultsForConversation(toLanguage: composerMode.get().0, text: nil)
                textView.resignFirstResponder()
                let fromRecord = GAIDictionaryBuilder.createEvent(withCategory: "Language", action: "FromLanguage", label: "\(LanguageManager().nameFromCode(composerMode.get().1!, localized: false))", value: 0)
                let toRecord = GAIDictionaryBuilder.createEvent(withCategory: "Language", action: "ToLanguage", label: "\(LanguageManager().nameFromCode(composerMode.get().0, localized: false))", value: 0)
                let countRecord = GAIDictionaryBuilder.createEvent(withCategory: "Translation", action: "Count", label: "", value: textView.text.characters.count as NSNumber!)
                let tracker = GAI.sharedInstance().defaultTracker
                tracker?.send(countRecord!.build() as [NSObject : AnyObject])
                tracker?.send(fromRecord!.build() as [NSObject : AnyObject])
                tracker?.send(toRecord!.build() as [NSObject : AnyObject])
                messageManager.requestTranslation(textToTranslate: textView.text, toCode: composerMode.get().0, fromCode: composerMode.get().1!, google: true)
            } else {
                textView.shake()
                bubble.shake()
            }
            
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
            self.composerMode = .Reply(message.originalLanguage, message.translatedLanguage)
            
            // Present keyboard etc. 
            self.textView.isEditable = true
            if savedText != nil {
                textView.text = savedText
            } else {
                self.textView.text = ""
            }
            
            self.textView.becomeFirstResponder()
        case .Reply:
            toggleSpinner()
            setDefaultsForConversation(toLanguage: composerMode.get().0, text: nil)
            textView.resignFirstResponder()
            NSLog("**** Looks like google bool is: \(composerMode.get().1!)")
            messageManager.requestTranslation(textToTranslate: textView.text, toCode: composerMode.get().0, fromCode: message.translatedLanguage, google: true)
        }
    }
    
    @IBAction func didTapRate(_ sender: UIButton) {
        
        if raterView == nil {
            // bring rater container to the front
            self.view.sendSubview(toBack: settingsContainer)
            NotificationCenter.default.addObserver(self, selector: #selector(self.didExitRatingView(notification:)), name: NSNotification.Name(rawValue: "RATED"), object: nil)
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
            self.raterView?.hideStars()
            self.raterView?.presentStars(withLanguage: message.translatedLanguage)
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
        }
    }
    
    func didExitRatingView(notification: Notification?) {
        if notification != nil {
            // send the rating to analytics from notification user info 
            
            // disable the rate button
            self.rateButton.isEnabled = false
            
            // remove the rater view
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
        self.settingsIsPresented = false
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
            self.settingsButton.isEnabled = true
            self.textView.isUserInteractionEnabled = true
            self.swapButton.isEnabled = true
            self.rateButton.isEnabled = true
            self.goButton.isEnabled = true
            
            self.textView.becomeFirstResponder()
        })
    }
    
    @IBAction func didTapSettings(_ sender: UIButton?) {
        self.view.sendSubview(toBack: raterContainer)
        settingsButton.isEnabled = false
        goButton.isEnabled = false
        swapButton.isEnabled = false
        rateButton.isEnabled = false
        textView.isUserInteractionEnabled = false
        settingsIsPresented = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopScroll), name: NSNotification.Name(rawValue: "STOP_SCROLL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startScroll), name: NSNotification.Name(rawValue: "START_SCROLL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissSettings), name: NSNotification.Name(rawValue: "DISMISS_SETTINGS"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.respondToNotification), name: NSNotification.Name(rawValue: "APPLY_THEME"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.presentMessage), name: NSNotification.Name(rawValue: "PRESENT_MESSAGE"), object: nil)
        
        if settingsView == nil {
            textView.resignFirstResponder()
            settingsView = Bundle.main.loadNibNamed("Settings", owner: self, options: nil)?.first as! Settings
            settingsContainer.addSubview(settingsView!)
            settingsView?.developerMode = developerMode
            settingsView?.loadDefaults(notification: nil)
            settingsView?.listContainer.isHidden = true 
            settingsView?.translatesAutoresizingMaskIntoConstraints = false
            settingsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":settingsView! as Settings]))

            settingsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":settingsView! as Settings]))
            
            self.view.layoutIfNeeded()
            if backgroundVertical.constant == topBarHeight {
                backgroundVertical.constant = topBarHeight + /*settingsContainerHeight.constant*/ 488
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
        }
    }
  
    func setDefaultsForConversation(toLanguage: String, text: String?) {
        var conversationDefaults = [String: String]()
        conversationDefaults["toLanguage"] = LanguageManager().nameFromCode(toLanguage, localized: true)
        if text != nil {
            conversationDefaults["savedText"] = text
        }
        let defaults = UserDefaults()
        if conversationIdentifier != nil {
            defaults.setValue(conversationDefaults, forKey: conversationIdentifier!)
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Send an error to analytics
    }
}
