//
//  Theme.swift
//  Unitrans
//
//  Created by Kim Rypstra on 19/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class Theme: NSObject {

    var name: String?
    var topColour: UIColor?
    var bottomColour: UIColor?
    var textColour: UIColor?
    var bubbleColour: UIColor?
    var buttonColour: UIColor?
    var focussedButtonColour: UIColor?
    var darkKeyboard: Bool?
    var imagePrefix: String?
    var isRichTheme: Bool
    var selectorTextColour: UIColor?
    
    init(name: String, topColour: UIColor, bottomColour: UIColor, textColour: UIColor, bubbleColour: UIColor?, buttonColour: UIColor?, focussedButtonColour: UIColor?, darkKeyboard: Bool, imagePrefix: String?, isRichTheme: Bool, selectorTextColour: UIColor?) {
        self.name = name 
        self.topColour = topColour
        self.bottomColour = bottomColour
        self.textColour = textColour
        self.bubbleColour = bubbleColour
        self.buttonColour = buttonColour
        self.focussedButtonColour = focussedButtonColour
        self.darkKeyboard = darkKeyboard
        self.imagePrefix = imagePrefix
        self.isRichTheme = isRichTheme
        self.selectorTextColour = selectorTextColour
    }
}
