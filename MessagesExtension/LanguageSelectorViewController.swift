//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Kim Rypstra on 8/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit
import Messages

class LanguageSelectorViewController: MSMessagesAppViewController, UIScrollViewDelegate {
    
    //IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewOffset: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backgroundView: BackgroundView!
    @IBOutlet weak var topIndicatorContainer: UIView!
    @IBOutlet weak var bottomIndicatorContainer: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var goButtonOffset: NSLayoutConstraint!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var settingsButtonOffset: NSLayoutConstraint!
    
    //Manager Classes
    let languageManager = LanguageManager()
    
    //Constants
    var languages = [Language]()
    var identifier: String?
    var subscribed: Bool?
    var fromLanguage: String?
    var themeToApply: Theme?
    var shouldScrollOnTap = true
    var scrollWasInitiatedByIndicator = false
    var shouldPresentSettings = false
    var stackViewFontColour: UIColor?
    var savedText: String?
    
    //Views
    var topIndicator: Indicators?
    var bottomIndicator: Indicators?
    
    var gai = GAI.sharedInstance()
    
    var developerMode = false 
    
    
    
    
    /*-----------------------------------------*/
    
    
    override func viewDidLoad() {
        
        
        applyTheme(notification: nil)
        designIndicators()
        setUpStackView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.insertMessage), name: NSNotification.Name(rawValue: "COMPOSED_MESSAGE"), object: nil)
        
        // Configure tracker from GoogleService-Info.plist.
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        //gai?.logger.logLevel = GAILogLevel.error  // remove before app release
 
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backgroundView.topColor = themeToApply?.topColour
        backgroundView.bottomColor = themeToApply?.bottomColour
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //
        super.viewDidAppear(animated)
    }
    
    
    
    func insertMessage(notification: Notification) {
        if let message = notification.userInfo?["Message"] as? MSMessage {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "COMPOSED_MESSAGE"), object: nil)
            self.activeConversation?.insert(message, completionHandler: { (error) in
                if error != nil {
                    print(error?.localizedDescription)
                    let error = GAIDictionaryBuilder.createException(withDescription: error.debugDescription, withFatal: 0)
                    GAI.sharedInstance().defaultTracker.send(error!.build() as [NSObject: AnyObject])
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error inserting message", code: 0)]))

                } else {
                    self.dismiss()
                }
            })
        } else {
            NSLog("**** No message")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "No message to insert", code: 0)]))

        }
    }
    
    func designIndicators() {
        let topView = Indicators().getView() as! Indicators
        
        topIndicator = topView
        if topIndicator != nil {
            topIndicatorContainer.addSubview(topIndicator!)
            topIndicator?.setupChevrons(colour: themeToApply!.focussedButtonColour!)
        }
        let bottomView = Indicators().getView() as! Indicators
        
        bottomIndicator = bottomView
        if bottomIndicator != nil {
            bottomIndicatorContainer.addSubview(bottomIndicator!)
            bottomIndicator?.setupChevrons(colour: themeToApply!.focussedButtonColour!)
            bottomIndicatorContainer.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI))
        }
        
        let topRecog = UITapGestureRecognizer(target: self, action: #selector(self.didTapIndicator))
        topRecog.accessibilityHint = "Scroll Up"
        let bottomRecog = UITapGestureRecognizer(target: self, action: #selector(self.didTapIndicator))
        bottomRecog.accessibilityHint = "Scroll Down"
        topIndicator?.addGestureRecognizer(topRecog)
        bottomIndicator?.addGestureRecognizer(bottomRecog)
        
    }
    
    func requestCompact() {
        self.requestPresentationStyle(.compact)
    }
    
    
    func didTapIndicator(sender: UITapGestureRecognizer) {
        if shouldScrollOnTap {
            switch sender.accessibilityHint! {
            case "Scroll Up":
                
                shouldScrollOnTap = false
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - scrollViewHeight.constant), animated: true)
            case "Scroll Down":
                
                shouldScrollOnTap = false
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y + scrollViewHeight.constant), animated: true)
            default:
                NSLog("**** Error")
            }
        }
        
    }
    
    func setUpStackView() {
        languages = languageManager.initialiseLanguages()
        languages.sort(by: { $0.localizedName < $1.localizedName })
        
        containerViewHeight.constant = CGFloat(languages.count) * scrollViewHeight.constant
        
        for number in 0...languages.count - 1 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: scrollViewHeight.constant))
            label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightHeavy)
            
            label.adjustsFontSizeToFitWidth = true
            var textColor: UIColor?
            if themeToApply?.selectorTextColour != nil {
                stackViewFontColour = themeToApply!.selectorTextColour!
            } else {
                stackViewFontColour = UIColor.white.withAlphaComponent(0.8)
            }
            label.textColor = stackViewFontColour
            label.numberOfLines = 2
            let name = NSMutableAttributedString(string: languages[number].localizedName, attributes: [NSForegroundColorAttributeName: stackViewFontColour!.withAlphaComponent(0.8)])
            if let native = languages[number].nativeName {
                let nativeName = NSMutableAttributedString(string: "\n\(native)", attributes: [NSForegroundColorAttributeName: stackViewFontColour!.withAlphaComponent(0.4)])
                name.append(nativeName)
            }
            
            
            label.lineBreakMode = .byWordWrapping
            label.attributedText = name
            
            label.textAlignment = .center
            label.addTextSpacing(spacing: 3.5) // adds kerning
            stackView.addArrangedSubview(label)
        }
    }
    
    func applyTheme(notification: Notification?) {
        
        let defaults = UserDefaults()
        if notification == nil {
            if let theme = defaults.value(forKey: "theme") as? String {
                
                themeToApply = ThemeManager().returnThemeOfName(name: theme)
            } else {
                NSLog("**** No theme selected; setting default")
                themeToApply = ThemeManager().returnThemeOfName(name: "Classic")
            }
        } else {
            if let theme = notification?.userInfo?["theme"] as? Theme {
                
                themeToApply = theme
            }
        }
        stackViewFontColour = themeToApply?.selectorTextColour
        backgroundView.topColor = themeToApply!.topColour!
        backgroundView.bottomColor = themeToApply!.bottomColour!
        
        //backgroundView.topColor = UIColor.white
        //backgroundView.bottomColor =  UIColor.white
        
        if themeToApply?.isRichTheme == true {
            //goButton.setImage(UIImage(named: "\(themeToApply!.imagePrefix!)GoButton"), for: .normal)
            goButton.setImage(UIImage(named: "maskedGoButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
            goButton.imageView?.tintColor = themeToApply?.selectorTextColour
            goButton.alpha = 1
        } else {
            goButton.setImage(UIImage(named:"rightArrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
            goButton.imageView?.tintColor = themeToApply?.buttonColour
        }
        
        if notification != nil {
            for view in stackView.arrangedSubviews {
                stackView.removeArrangedSubview(view)
            }
            designIndicators()
            setUpStackView()           
        }
        
        backgroundView.setNeedsDisplay()
        
    }
    
    func loadDefaults(conversation: MSConversation) {
        // load user defaults
        
        let defaults = UserDefaults()
        var defaultsArray = [String: String]()
        var ids = [String]()
        for id in conversation.remoteParticipantIdentifiers {
            ids.append(id.uuidString)
        }
        
        let sortedIDs = ids.sorted()
        identifier = sortedIDs.joined(separator: "+")
        if let subscriptionStatus = defaults.value(forKey: "subscribed") as? Bool {
            // the subscription key is there...
            if subscriptionStatus == true {
                // they are subscribed
                subscribed = true
                if let conversationDefaults = defaults.value(forKey: identifier!) as? [String: String] {
                    if let toLanguage = conversationDefaults["toLanguage"] {
                        // set the scrollView to the appropriate page
                        if let index = languages.index(of: languages.filter{ $0.englishName == toLanguage }.first!) {
                            scrollView.contentOffset.y = scrollViewHeight.constant * CGFloat(index)
                            
                        } else {
                            NSLog("**** No preset 'to' language")
                        }
                    } else {
                        NSLog("**** No record of conversation defaults for this identifier")
                    }
                    
                    if let savedText = conversationDefaults["savedText"] as? String {
                        self.savedText = savedText
                    }
                } else {
                    NSLog("**** No record of this conversation's identifier; must be a new conversation")
                }

            } else {
                // they are not subscribed
                if developerMode == true {
                    subscribed = true
                } else {
                    subscribed = false
                }
                
            }
        } else {
            // they are not subscribed
            if developerMode == true {
                subscribed = true
            } else {
                subscribed = false
            }
        }
        NSLog("**** Subscribed: \(subscribed!)")
        
        if let fromLanguage = defaults.value(forKey: "fromLanguage") as? String {
            NSLog("**** From language: \(fromLanguage)")
            self.fromLanguage = fromLanguage
        } else {
            NSLog("**** No 'from' language set; setting default from device")
            if var language = NSLocale.preferredLanguages.first {
                NSLog("**** Detected device language: \(language)")
                if language.contains("-Hans") {
                    NSLog("**** Language is Chinese Simplified")
                    self.fromLanguage = "zh"
                } else if language.contains("-Hant") {
                    NSLog("**** Language is Chinese Traditional")
                    self.fromLanguage = "zh-TW"
                    
                } else {
                    switch language {
                    case "zh-TW":
                        NSLog("**** Language is zh-TW")
                        self.fromLanguage = language
                    case "zh-CN":
                        NSLog("**** Language is zh-CN")
                        self.fromLanguage = language
                    case nil:
                        NSLog("**** There doesn't appear to be a device language set? Setting to English...")
                        self.fromLanguage = "en"
                    default:
                        // For all other language cases
                        if let range = language.range(of: "-") {
                            language = language.substring(to: range.lowerBound)
                        }
                        self.fromLanguage = language
                    }
                }
                
                NSLog("**** From language set to: \(self.fromLanguage!)")
            }
        }

        // if the language's 'page' is 0 in the scroll view, hide the top indicator (or bottom if it's the last)
        scrollViewDidScroll(self.scrollView)

    }
    
    func returnUIToNormal() {
        // This is called when the app returns to compact presentation style 
        let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {(Timer) -> Void in
            // first element
            self.goButtonOffset.constant = 10
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.goButton.alpha = 1
                self.view.layoutIfNeeded()
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {(Timer) -> Void in
            // second element
            self.scrollViewOffset.constant = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.scrollView.alpha = 1
                self.topIndicator?.alpha = 1
                self.bottomIndicator?.alpha = 1
                self.view.layoutIfNeeded()
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {(Timer) -> Void in
            // third element
            self.settingsButtonOffset.constant = 30
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                
            })
        })
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {(Timer) -> Void in
            // first element
            self.goButtonOffset.constant += 300
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.goButton.alpha = 0
                self.view.layoutIfNeeded()
            })
        })
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {(Timer) -> Void in
            // second element
            self.scrollViewOffset.constant -= 200
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.scrollView.alpha = 0
                self.topIndicator?.alpha = 0
                self.bottomIndicator?.alpha = 0
                self.view.layoutIfNeeded()
            })
        })

        let _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {(Timer) -> Void in
            // third element
            self.settingsButtonOffset.constant -= 200
            UIView.animate(withDuration: 0.2, animations: {      
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                self.requestPresentationStyle(.expanded)
            })
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        shouldScrollOnTap = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        switch offset {
        case 0:
            UIView.animate(withDuration: 0.2, animations: {
                self.topIndicator?.alpha = 0
            })
        case containerViewHeight.constant - scrollViewHeight.constant:
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomIndicator?.alpha = 0
            })
        default:
            UIView.animate(withDuration: 0.2, animations: {
                self.topIndicator?.alpha = 1
                self.bottomIndicator?.alpha = 1
            })
        }

        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        shouldScrollOnTap = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        shouldScrollOnTap = true
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //This takes the targeted end-point of the scroll and adjusts it so that it hits a 'page', but without using the aggressive pagination of a page-enabled scroll view
        targetContentOffset.pointee.y = scrollViewHeight.constant * round(targetContentOffset.pointee.y / scrollViewHeight.constant)
        
    }
    
    
    // MARK: - Conversation Handlingw
    
    override func didBecomeActive(with conversation: MSConversation) {
        
        loadDefaults(conversation: conversation)
        if conversation.selectedMessage == nil {
            // no message has been selected and the app should launch into compact
        } else {
            self.performSegue(withIdentifier: "toExpanded", sender: self)
            // a message was selected and the app should launch into expanded, which will trigger the segue to the expanded view controller
        }
        super.didBecomeActive(with: conversation)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        switch presentationStyle {
        case .compact:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GOING_TO_COMPACT"), object: nil, userInfo: nil)
        default:
            break
        }
        
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func willResignActive(with conversation: MSConversation) {
        // send a notification 
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "WILL_RESIGN")))
        // in the other VC, save text to defaults
        // on load, if there is saved text, set textView.text to it
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        switch presentationStyle {
        case .expanded:
            self.performSegue(withIdentifier: "toExpanded", sender: self)
        case .compact:
            scrollViewDidScroll(self.scrollView)
            returnUIToNormal()
        default:
            break
        }
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "toExpanded":
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "APPLY_THEME"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.applyTheme), name: NSNotification.Name(rawValue: "APPLY_THEME"), object: nil)
            let IVC = segue.destination as! ExpandedViewController
            IVC.conversationIdentifier = identifier
            IVC.developerMode = self.developerMode
            IVC.theme = self.themeToApply
            IVC.subscribed = self.subscribed
            IVC.savedText = self.savedText
            
            if shouldPresentSettings {
                IVC.shouldPresentSettings = true 
            }
            
            if self.activeConversation?.selectedMessage == nil {
                let pageNumber: Int = Int(scrollView.contentOffset.y / scrollViewHeight.constant)
                if languages[pageNumber].prefersGoogle == true {
                    IVC.composerMode = .Compose(languages[pageNumber].googleCode!, fromLanguage!)
                } else {
                    IVC.composerMode = .Compose(languages[pageNumber].microsoftCode!, fromLanguage!)
                }
                
            } else {
                let messageURL = self.activeConversation?.selectedMessage?.url?.absoluteString
                IVC.composerMode = .View(messageURL!)
            }
        default: break
        }
    }

}
