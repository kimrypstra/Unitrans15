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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backgroundView: BackgroundView!
    @IBOutlet weak var topIndicatorContainer: UIView!
    @IBOutlet weak var bottomIndicatorContainer: UIView!
    
    //Manager Classes
    let languageManager = LanguageManager()
    let connectionManager = ConnectionManager()
    
    //Constants
    
    
    //Views
    var topIndicator: Indicators?
    var bottomIndicator: Indicators?
    
    
    /*-----------------------------------------*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designIndicators()
        setUpStackView()
        
        // Do any additional setup after loading the view.
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
    }
    
    func setUpStackView() {
        let languages = languageManager.getLocalizedLanguageNames()
        containerViewHeight.constant = CGFloat(languageManager.languageCount()) * scrollViewHeight.constant
        
        for number in 0...languages.count - 1 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: scrollViewHeight.constant))
            label.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightHeavy)
            label.textColor = UIColor.white.withAlphaComponent(0.8)
            label.numberOfLines = 2
            label.text = "\(languages[number])\n\(languageManager.getNativeLanguageName(name: languages[number]))"
            label.textAlignment = .center
            label.addTextSpacing(spacing: 3.5)
            stackView.addArrangedSubview(label)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            topIndicator?.isHidden = true
        } else if scrollView.contentOffset.y >= containerViewHeight.constant + scrollViewHeight.constant - 1 {
            bottomIndicator?.isHidden = true
        } else {
            if (topIndicator?.isHidden)! {
                topIndicator?.isHidden = false
            }
            if (bottomIndicator?.isHidden)! {
                bottomIndicator?.isHidden = false
            }
        }
        print("Offset: \(scrollView.contentOffset.y + scrollViewHeight.constant), Height: \(containerViewHeight.constant)")
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
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
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
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
