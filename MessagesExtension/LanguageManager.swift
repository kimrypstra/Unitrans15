//
//  File.swift
//  UniversalTranslator
//
//  Created by Kim Rypstra on 23/07/2016.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import Foundation

class LanguageManager {
    private var version = 0.1
    
    private var localizedLanguages: [String : String] = [
        NSLocalizedString("Afrikaans", comment: "Language"):"af",
        NSLocalizedString("Arabic", comment: "Language"):"ar",
        NSLocalizedString("Bosnian (Latin)", comment: "Language"):"bs-Latn",
        NSLocalizedString("Bulgarian", comment: "Language"):"bg",
        NSLocalizedString("Catalan", comment: "Language"):"ca",
        NSLocalizedString("Chinese Simplified", comment: "Language"):"zh-CHS",
        NSLocalizedString("Chinese Traditional", comment: "Language"):"zh-CHT",
        NSLocalizedString("Croatian", comment: "Language"):"hr",
        NSLocalizedString("Czech", comment: "Language"):"cs",
        NSLocalizedString("Danish", comment: "Language"):"da",
        NSLocalizedString("Dutch", comment: "Language"):"nl",
        NSLocalizedString("English", comment: "Language"):"en",
        NSLocalizedString("Estonian", comment: "Language"):"et",
        NSLocalizedString("Finnish", comment: "Language"):"fi",
        NSLocalizedString("French", comment: "Language"):"fr",
        NSLocalizedString("German", comment: "Language"):"de",
        NSLocalizedString("Greek", comment: "Language"):"el",
        NSLocalizedString("Haitian Creole", comment: "Language"):"ht",
        NSLocalizedString("Hebrew", comment: "Language"):"he",
        NSLocalizedString("Hindi", comment: "Language"):"hi",
        NSLocalizedString("Hmong Daw", comment: "Language"):"mww",
        NSLocalizedString("Hungarian", comment: "Language"):"hu",
        NSLocalizedString("Indonesian", comment: "Language"):"id",
        NSLocalizedString("Italian", comment: "Language"):"it",
        NSLocalizedString("Japanese", comment: "Language"):"ja",
        NSLocalizedString("Kiswahili", comment: "Language"):"sw",
        NSLocalizedString("Klingon", comment: "Language"):"tlh",
        NSLocalizedString("Korean", comment: "Language"):"ko",
        NSLocalizedString("Latvian", comment: "Language"):"lv",
        NSLocalizedString("Lithuanian", comment: "Language"):"lt",
        NSLocalizedString("Malay", comment: "Language"):"ms",
        NSLocalizedString("Maltese", comment: "Language"):"mt",
        NSLocalizedString("Norwegian", comment: "Language"):"no",
        NSLocalizedString("Persian", comment: "Language"):"fa",
        NSLocalizedString("Polish", comment: "Language"):"pl",
        NSLocalizedString("Portuguese", comment: "Language"):"pt",
        NSLocalizedString("Querétaro Otomi", comment: "Language"):"otq",
        NSLocalizedString("Romanian", comment: "Language"):"ro",
        NSLocalizedString("Russian", comment: "Language"):"ru",
        NSLocalizedString("Serbian (Cyrillic)", comment: "Language"):"sr-Cyrl",
        NSLocalizedString("Serbian (Latin)", comment: "Language"):"sr-Latn",
        NSLocalizedString("Slovak", comment: "Language"):"sk",
        NSLocalizedString("Slovenian", comment: "Language"):"sl",
        NSLocalizedString("Spanish", comment: "Language"):"es",
        NSLocalizedString("Swedish", comment: "Language"):"sv",
        NSLocalizedString("Thai", comment: "Language"):"th",
        NSLocalizedString("Turkish", comment: "Language"):"tr",
        NSLocalizedString("Ukrainian", comment: "Language"):"uk",
        NSLocalizedString("Urdu", comment: "Language"):"ur",
        NSLocalizedString("Vietnamese", comment: "Language"):"vi",
        NSLocalizedString("Welsh", comment: "Language"):"cy",
        NSLocalizedString("Yucatec Maya", comment: "Language"):"yua"
    ]
    
    private var englishLanguages: [String : String] = [
        "Afrikaans" : "af",
        "Arabic" : "ar", //RTL
        "Bosnian (Latin)" :	"bs-Latn",
        "Bulgarian" : "bg",
        "Catalan":"ca",
        "Chinese Simplified":"zh-CHS",
        "Chinese Traditional":"zh-CHT",
        "Croatian":"hr",
        "Czech":"cs",
        "Danish"	:	"da",
        "Dutch"	:	"nl",
        "English"	:	"en",
        "Estonian"	:	"et",
        "Finnish"	:	"fi",
        "French"	:	"fr",
        "German"	:	"de",
        "Greek"	:	"el",
        "Haitian Creole"	:	"ht",
        "Hebrew"	:	"he", //RTL
        "Hindi"	:	"hi",
        "Hmong Daw"	:	"mww",
        "Hungarian"	:	"hu",
        "Indonesian"	:	"id",
        "Italian"	:	"it",
        "Japanese"	:	"ja",
        "Kiswahili"	:	"sw",
        "Klingon"	:	"tlh",
        "Korean"	:	"ko",
        "Latvian"	:	"lv",
        "Lithuanian"	:	"lt",
        "Malay"	:	"ms",
        "Maltese"	:	"mt",
        "Norwegian"	:	"no",
        "Persian"	:	"fa",
        "Polish"	:	"pl",
        "Portuguese"	:	"pt",
        "Querétaro Otomi"	:	"otq",
        "Romanian"	:	"ro",
        "Russian"	:	"ru",
        "Serbian (Cyrillic)"	:	"sr-Cyrl",
        "Serbian (Latin)"	:	"sr-Latn",
        "Slovak"	:	"sk",
        "Slovenian"	:	"sl",
        "Spanish"	:	"es",
        "Swedish"	:	"sv",
        "Thai"	:	"th",
        "Turkish"	:	"tr",
        "Ukrainian"	:	"uk",
        "Urdu"	:	"ur",
        "Vietnamese"	:	"vi",
        "Welsh"	:	"cy",
        "Yucatec Maya"	:	"yua"
    ]
    
    let languagesTranslatedToOwnLanguage = [
        "Japanese" : "日本語"
    ]
    
    func getNativeLanguageName(name: String) -> String {
        // Returns the language name given in it's OWN language
        
        let nativeName = languagesTranslatedToOwnLanguage[name]
        if nativeName != nil {
            return nativeName!
        } else {
            return "You should finish this list"
        }
    }
    
    func getLocalizedLanguageNames() -> [String] {
        // Returns all language names (translated)
        
        let array = Array(localizedLanguages.keys)
        return array.sorted()
    }
    
    func languageCount() -> Int {
        return localizedLanguages.count
    }
    
    func nameFromCode(_ code: String, localized: Bool) -> String? {
        // For getting the corresponding name for a language code, either in english or translated
        
        var languages = [String : String]()
        if localized {
            languages = localizedLanguages
        } else {
            languages = englishLanguages
        }
        
        var returnString: String?
        
        for item in languages {
            if item.value == code {
                returnString = item.key
            }
        }
        
        return returnString
        
        /*
        let arrayOfLanguageNames = Array(languages.keys)
        var flipped = [String : String]()
        for languageName in arrayOfLanguageNames {
            if let languageCode = languages[languageName] {
                // returns languages in english only
                 flipped[languageCode] = languageName
            }
        }
        if flipped[code] != nil {
            return flipped[code]
        } else {
            print("Error!")
            return "Error!"
        }
         */
        
    }
    
    func codeFromLanguageName(_ name: String) -> String? {
        // Returns the language code for a given language name
        
        var returnValue: String?
        if let languageCode = localizedLanguages[name] {
            returnValue = languageCode
        }
        return returnValue
    }
    
    func sanitiseEmoji(_ text: String) -> String? {
        // Takes in a string, and if it contains emoji, puts a single space between it and any normal characters so that the translator can read the words properly
        
        let characterSet = NSMutableCharacterSet(range: NSRange(location: 0x1F300, length: 0x1F700 - 0x1F300))
        var emojiPresent = false
        
        // First, split the string into characters as String (text.characters returns CharacterViews, not Strings)
        let arrayOfCharacters = text.characters
        var arrayOfCharactersAsString = [String]()
        for char in arrayOfCharacters {
            let charString = String(char)
            arrayOfCharactersAsString.append(charString)
        }
        
        // Second, inspect each character to see if it is an emoji
        var index = 0
        for char in arrayOfCharactersAsString {
            if char.rangeOfCharacter(from: characterSet as CharacterSet) != nil {
                print("Emoji present: \(char) at index \(index) ")
                emojiPresent = true
                if index > 0 {
                    if arrayOfCharactersAsString[index - 1] != " " {
                        arrayOfCharactersAsString.insert(" ", at: index)
                    }
                    if index < arrayOfCharactersAsString.count - 1 {
                        if arrayOfCharactersAsString[index + 1] != " " {
                            arrayOfCharactersAsString.insert(" ", at: index + 1)
                        }
                    }
                }
            }
            index += 1
        }
        
        // If emoji were detected, return the sanitised string. Otherwise, spit out the same old text passed in originally.
        var sanitised: String?
        if emojiPresent {
            let array = arrayOfCharactersAsString.flatMap { $0.characters }
            sanitised = String(array)
        } else {
            sanitised = text
        }
        
        return sanitised
    }
}
