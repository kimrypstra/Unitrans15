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
    
    //Views
    var topIndicator: Indicators?
    var bottomIndicator: Indicators?
    
    
    /*-----------------------------------------*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designIndicators()
        setUpStackView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.insertMessage), name: NSNotification.Name(rawValue: "COMPOSED_MESSAGE"), object: nil)
        
        //load user defaults and set scrollView to that language
        // Do any additional setup after loading the view.
        /*
        let marker = UIView(frame: CGRect(x: self.view.frame.width / 2, y: 0, width: 1, height: self.view.frame.height))
        marker.backgroundColor = UIColor.red
        self.view.addSubview(marker)
        */
    }
    
    func insertMessage(notification: Notification) {
        if let message = notification.userInfo?["Message"] as? MSMessage {
            print("Got message")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "COMPOSED_MESSAGE"), object: nil)
            self.activeConversation?.insert(message, completionHandler: { (error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    self.dismiss()
                }
            })
        } else {
            print("No message")
        }
    }
    
    func designIndicators() {
        let topView = Indicators().getView() as! Indicators
        
        topIndicator = topView
        if topIndicator != nil {
            topIndicatorContainer.addSubview(topIndicator!)
            topIndicator?.setupChevrons()
        }
        let bottomView = Indicators().getView() as! Indicators
        
        bottomIndicator = bottomView
        if bottomIndicator != nil {
            bottomIndicatorContainer.addSubview(bottomIndicator!)
            bottomIndicator?.setupChevrons()
            bottomIndicatorContainer.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI))
        }
        
        let topRecog = UITapGestureRecognizer(target: self, action: #selector(self.didTapIndicator))
        topRecog.accessibilityHint = "Scroll Up"
        let bottomRecog = UITapGestureRecognizer(target: self, action: #selector(self.didTapIndicator))
        bottomRecog.accessibilityHint = "Scroll Down"
        topIndicator?.addGestureRecognizer(topRecog)
        bottomIndicator?.addGestureRecognizer(bottomRecog)
        
    }
    
    func didTapIndicator(sender: UITapGestureRecognizer) {
        switch sender.accessibilityHint! {
        case "Scroll Up":
            print("Tap UP")
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - scrollViewHeight.constant), animated: true)
        case "Scroll Down":
            print("Tap DOWN")
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y + scrollViewHeight.constant), animated: true)
        default:
            print("Error")
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
            label.textColor = UIColor.white.withAlphaComponent(0.8)
            label.numberOfLines = 2
            let name = NSMutableAttributedString(string: languages[number].englishName, attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
            if let native = languages[number].nativeName {
                let nativeName = NSMutableAttributedString(string: "\n\(native)", attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.4)])
                name.append(nativeName)
            }
            
            
            label.lineBreakMode = .byWordWrapping
            label.attributedText = name
            
            label.textAlignment = .center
            label.addTextSpacing(spacing: 3.5)
            stackView.addArrangedSubview(label)
        }
    }
    
    func loadDefaults(conversation: MSConversation) {
        // load user defaults
        print("Loading defaults...")
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
                            print("Loaded to language: \(toLanguage)")
                        } else {
                            print("No preset 'to' language")
                        }
                    } else {
                        print("No record of conversation defaults for this identifier")
                    }
                } else {
                    print("No record of this conversation's identifier; must be a new conversation")
                }
                
                if let theme = defaults.value(forKey: "theme") as? String {
                    print("Theme: \(theme)")
                } else {
                    print("No theme selected; setting default")
                }

            } else {
                // they are not subscribed
                subscribed = false
            }
        } else {
            // they are not subscribed
            subscribed = false
        }
        
        if let fromLanguage = defaults.value(forKey: "fromLanguage") as? String {
            print("From language: \(fromLanguage)")
        } else {
            print("No 'from' language set; setting default from device")
            let language = NSLocale.preferredLanguages.first
            print("Device language: \(language!)")
            
            
        }
        
        print("Subscribed: \(subscribed!)")
        
        // if the language's 'page' is 0 in the scroll view, hide the top indicator (or bottom if it's the last)
        scrollViewDidScroll(self.scrollView)

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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //This takes the targeted end-point of the scroll and adjusts it so that it hits a 'page', but without using the aggressive pagination of a page-enabled scroll view
        targetContentOffset.pointee.y = scrollViewHeight.constant * round(targetContentOffset.pointee.y / scrollViewHeight.constant)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {

    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        loadDefaults(conversation: conversation)
        if conversation.selectedMessage == nil {
            // no message has been selected and the app should launch into compact
        } else {
            self.performSegue(withIdentifier: "toExpanded", sender: self)
            // a message was selected and the app should launch into expanded, which will trigger the segue to the expanded view controller
        }
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
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        switch presentationStyle {
        case .expanded:
            self.performSegue(withIdentifier: "toExpanded", sender: self)
        default:
            break
        }
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "toExpanded":
            let IVC = segue.destination as! ExpandedViewController
            IVC.conversationIdentifier = identifier
            if self.activeConversation?.selectedMessage == nil {
                let pageNumber: Int = Int(scrollView.contentOffset.y / scrollViewHeight.constant)
                if languages[pageNumber].prefersGoogle == true {
                    IVC.composerMode = .Compose(languages[pageNumber].googleCode!, true)
                } else {
                    IVC.composerMode = .Compose(languages[pageNumber].microsoftCode!, false)
                }
                
            } else {
                let messageURL = self.activeConversation?.selectedMessage?.url?.absoluteString
                IVC.composerMode = .View(messageURL!)
            }
        default: break
        }
    }

}
