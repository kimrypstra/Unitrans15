//
//  ThemeManager.swift
//  Unitrans
//
//  Created by Kim Rypstra on 19/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class ThemeManager: NSObject {

    private var availableThemes = [Theme(
        name: "Sky Blue",
        topColour: UIColor(red: 196/255, green: 227/255, blue: 255/255, alpha: 1),
        bottomColour: UIColor(red: 191/255, green: 210/255, blue: 255/255, alpha: 1),
        textColour: UIColor(red: 119/255, green: 150/255, blue: 178/255, alpha: 1),
        bubbleColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
        buttonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2),
        focussedButtonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
        darkKeyboard: false,
        imagePrefix: nil),
        Theme(
        name: "Pink",
        topColour: UIColor(red: 255/255, green: 209/255, blue: 253/255, alpha: 1),
        bottomColour: UIColor(red: 255/255, green: 146/255, blue: 253/255, alpha: 1),
        textColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
        bubbleColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
        buttonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2),
        focussedButtonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
        darkKeyboard: true,
        imagePrefix: nil),
        Theme(
        name: "Sunset",
        topColour: UIColor(red: 255/255, green: 223/255, blue: 176/255, alpha: 1),
        bottomColour: UIColor(red: 161/255, green: 121/255, blue: 204/255, alpha: 1),
        textColour: UIColor(red: 178/255, green: 149/255, blue: 106/255, alpha: 1),
        bubbleColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
        buttonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2),
        focussedButtonColour: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
        darkKeyboard: false,
        imagePrefix: nil),
    ]
    
    let color = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    override init() {
        print("INIT")
            }
    
    func themes() -> [Theme]? {
        return availableThemes
    }
    
    func returnThemeOfName(name: String) -> Theme {
        return availableThemes.first!
    }
    
}
