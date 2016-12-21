//
//  ThemeManager.swift
//  Unitrans
//
//  Created by Kim Rypstra on 19/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class ThemeManager: NSObject {

    private var availableThemes = [
        Theme(
            name: "Classic",
            topColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            bottomColour: UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1),
            textColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            bubbleColour: nil,
            buttonColour: nil,
            focussedButtonColour: UIColor(red: 174/255, green: 200/255, blue: 241/255, alpha: 1),
            darkKeyboard: false,
            imagePrefix: "classic",
            isRichTheme: true,
            selectorTextColour: UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 0.8)),
        Theme(
            name: "Dark",
            topColour: UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1),
            bottomColour: UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1),
            textColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            bubbleColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            buttonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2),
            focussedButtonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            darkKeyboard: true,
            imagePrefix: nil,
            isRichTheme: false,
            selectorTextColour: nil),
        Theme(
            name: "Contrast",
            topColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            bottomColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            textColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            bubbleColour: UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1),
            buttonColour: UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1),
            focussedButtonColour: UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1),
            darkKeyboard: true,
            imagePrefix: nil,
            isRichTheme: false,
            selectorTextColour: UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)),
        Theme(
            name: "Sky Blue",
            topColour: UIColor(red: 196/255, green: 227/255, blue: 255/255, alpha: 1),
            bottomColour: UIColor(red: 191/255, green: 210/255, blue: 255/255, alpha: 1),
            textColour: UIColor(red: 119/255, green: 150/255, blue: 178/255, alpha: 1),
            bubbleColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            buttonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            focussedButtonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            darkKeyboard: false,
            imagePrefix: nil,
            isRichTheme: false,
            selectorTextColour: nil),
        Theme(
            name: "Pink",
            topColour: UIColor(red: 255/255, green: 209/255, blue: 253/255, alpha: 1),
            bottomColour: UIColor(red: 255/255, green: 146/255, blue: 253/255, alpha: 1),
            textColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            bubbleColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            buttonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            focussedButtonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            darkKeyboard: false,
            imagePrefix: nil,
            isRichTheme: false,
            selectorTextColour: nil),
        Theme(
            name: "Sunset",
            topColour: UIColor(red: 162/255, green: 102/255, blue: 227/255, alpha: 0.8),
            bottomColour: UIColor(red: 252/255, green: 160/255, blue: 109/255, alpha: 0.8),
            textColour: UIColor(red: 162/255, green: 102/255, blue: 227/255, alpha: 0.8),
            bubbleColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            buttonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            focussedButtonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
            darkKeyboard: true,
            imagePrefix: nil,
            isRichTheme: false,
            selectorTextColour: nil)
    ]
    
    let color = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    override init() {
        print("INIT")
            }
    
    func themes() -> [Theme]? {
        return availableThemes
    }
    
    func returnThemeOfName(name: String) -> Theme? {
        return availableThemes.filter{ $0.name == name }.first
    }
    
}
