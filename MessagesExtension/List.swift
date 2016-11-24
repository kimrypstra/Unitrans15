//
//  List.swift
//  Unitrans
//
//  Created by Kim Rypstra on 14/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class List: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var listViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var data: [String: String]?
    var themes: [Theme]?
    var nibName: String?
    var selected: String?
    let checkmarkColor = UIColor(colorLiteralRed: 133/255, green: 133/255, blue: 133/255, alpha: 1)
    func setup(mode: String) {
        print(mode)
        if mode == "languages" {
            data = LanguageManager().nativeNames
            nibName = "CustomCell"
        } else if mode == "themes" {
            themes = ThemeManager().themes()
            nibName = "ThemeCell"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        // find the current language either from user defaults or the device's language
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nibName == "CustomCell" {
            return data!.count
        } else {
            return themes!.count
        }
        
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if nibName == "CustomCell" {
            let cell = Bundle.main.loadNibNamed(nibName!, owner: self, options: nil)?.first as! CustomCell
            cell.autoresizingMask = .flexibleLeftMargin
            if indexPath.row > 0 {
                let native = data?.keys.sorted()[indexPath.row - 1]
                cell.mainLabel.text = native
                if native == "Amharic" {
                    cell.nativeLabel.font = UIFont(name: "Kefa", size: 17)
                } else {
                    cell.nativeLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
                }
                cell.nativeLabel.text = data?[native!]
     
            } else {
                cell.mainLabel.text = "Automatic"
            }
            
            if cell.mainLabel.text == selected {
                cell.accessoryType = .checkmark
                cell.tintColor = checkmarkColor
            } else {
                cell.accessoryType = .none
            }
            // if the cell is the current from language, put a tick there
            return cell
        } else if nibName == "ThemeCell" {
            let cell = Bundle.main.loadNibNamed(nibName!, owner: self, options: nil)?.first as! ThemeCell
            let theme = themes?[indexPath.row]
            cell.nameLabel.text = theme?.name
            cell.nameLabel.textColor = theme?.textColour
            cell.background.topColor = theme?.topColour
            cell.background.bottomColor = theme?.bottomColour
            cell.bubble.image = UIImage(named: "bubble")?.withRenderingMode(.alwaysTemplate)
            cell.bubble.tintColor = theme?.bubbleColour
            // if the cell is the current from language, put a tick there
            
            if cell.nameLabel.text == selected {
                cell.accessoryType = .checkmark
                cell.tintColor = theme?.textColour
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed(nibName!, owner: self, options: nil)?.first as! CustomCell
            let native = data?.keys.sorted()[indexPath.row]
            cell.mainLabel.text = native
            if native == "Amharic" {
                cell.nativeLabel.font = UIFont(name: "Kefa", size: 17)
            } else {
                cell.nativeLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
            }
            cell.nativeLabel.text = data?[native!]
            
            // if the cell is the current from language, put a tick there
            
            return cell
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch list")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row")
        let defaults = UserDefaults()
        if nibName == "CustomCell" {
            if indexPath.row > 0 {
                let languageCode = LanguageManager().codeFromLanguageName((data?.keys.sorted()[indexPath.row - 1])!)
                
                // *** For some reason the top row isn't responding to scroll or selection ***
                
                defaults.setValue(languageCode, forKey: "fromLanguage")
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                defaults.setValue(nil, forKey: "fromLanguage")
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD")))
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_LANGUAGES")))
        } else {
            let themeName = themes?[indexPath.row].name
            
            defaults.set(themeName, forKey: "theme")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD")))
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_LANGUAGES")))
        }
        
        
        
    }

}
