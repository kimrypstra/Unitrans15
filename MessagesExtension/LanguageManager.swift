//
//  File.swift
//  UniversalTranslator
//
//  Created by Kim Rypstra on 23/07/2016.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import Foundation

class LanguageManager {
    
    private let google = [
        "Afrikaans":"af",
        "Albanian":"sq",
        "Arabic":"ar",
        "Armenian":"hy",
        "Azerbaijani":"az",
        "Basque":"eu",
        "Belarusian":"be",
        "Bengali":"bn",
        "Bosnian":"bs",
        "Bulgarian":"bg",
        "Catalan":"ca",
        "Cebuano":"ceb",
        "Chichewa":"ny",
        "Chinese Traditional":"zh-TW",
        "Chinese Simplified":"zh",
        "Corsican":"co",
        "Croatian":"hr",
        "Czech":"cs",
        "Danish":"da",
        "Dutch":"nl",
        "English":"en",
        "Esperanto":"eo",
        "Estonian":"et",
        "Filipino":"tl",
        "Finnish":"fi",
        "French":"fr",
        "Frisian":"fy",
        "Galician":"gl",
        "Georgian":"ka",
        "German":"de",
        "Greek":"el",
        "Gujarati":"gu",
        "Haitian Creole":"ht",
        "Hausa":"ha",
        "Hawaiian":"haw",
        "Hebrew":"iw",
        "Hindi":"hi",
        "Hmong":"hmn",
        "Hungarian":"hu",
        "Icelandic":"is",
        "Igbo":"ig",
        "Indonesian":"id",
        "Irish":"ga",
        "Italian":"it",
        "Japanese":"ja",
        "Javanese":"jw",
        "Kannada":"kn",
        "Kazakh":"kk",
        "Khmer":"km",
        "Korean":"ko",
        "Kurdish (Kurmanji)":"ku",
        "Kyrgyz":"ky",
        "Lao":"lo",
        "Latin":"la",
        "Latvian":"lv",
        "Lithuanian":"lt",
        "Luxembourgish":"lb",
        "Macedonian":"mk",
        "Malagasy":"mg",
        "Malay":"ms",
        "Malayalam":"ml",
        "Maltese":"mt",
        "Maori":"mi",
        "Marathi":"mr",
        "Mongolian":"mn",
        "Myanmar (Burmese)":"my",
        "Nepali":"ne",
        "Norwegian":"no",
        "Pashto":"ps",
        "Persian":"fa",
        "Polish":"pl",
        "Portuguese":"pt",
        "Punjabi":"pa",
        "Romanian":"ro",
        "Russian":"ru",
        "Samoan":"sm",
        "Scots Gaelic":"gd",
        "Serbian (Cyrillic)":"sr",
        "Sesotho":"st",
        "Shona":"sn",
        "Sindhi":"sd",
        "Sinhala":"si",
        "Slovak":"sk",
        "Slovenian":"sl",
        "Somali":"so",
        "Spanish":"es",
        "Sundanese":"su",
        "Swahili":"sw",
        "Swedish":"sv",
        "Tajik":"tg",
        "Tamil":"ta",
        "Telugu":"te",
        "Thai":"th",
        "Turkish":"tr",
        "Ukrainian":"uk",
        "Urdu":"ur",
        "Uzbek":"uz",
        "Vietnamese":"vi",
        "Welsh":"cy",
        "Xhosa":"xh",
        "Yiddish":"yi",
        "Yoruba":"yo",
        "Zulu":"zu"]
    
    let nativeNames = [
        "Afrikaans":"Afrikaans",
        "Albanian":"Shqiptar",
        "Arabic":"العربية",
        "Armenian":"հայերեն",
        "Azerbaijani":"Azərbaycan",
        "Basque":"Euskal",
        "Belarusian":"беларускі",
        "Bengali":"বাঙালি",
        "Bosnian":"Bosanski",
        "Bulgarian":"български",
        "Catalan":"Català",
        "Cebuano":"Cebuano",
        "Chichewa":"Chichewa",
        "Chinese Traditional":"中國傳統的",
        "Chinese Simplified":"简体中文",
        "Corsican":"Corsu",
        "Croatian":"Hrvatski",
        "Czech":"Čeština",
        "Danish":"Dansk",
        "Dutch":"Nederlands",
        "English":"English",
        "Esperanto":"Esperanto",
        "Estonian":"Eesti",
        "Filipino":"Pilipino",
        "Finnish":"Suomalainen",
        "French":"Français",
        "Frisian":"Frysk",
        "Galician":"Galego",
        "Georgian":"ქართული",
        "German":"Deutsche",
        "Greek":"ελληνικά",
        "Gujarati":"ગુજરાતી",
        "Haitian Creole":"Kreyòl ayisyen",
        "Hausa":"Hausa",
        "Hawaiian":"ʻŌlelo Hawaiʻi",
        "Hebrew":"עִברִית",
        "Hindi":"हिंदी",
        "Hmong":"Hmong",
        "Hungarian":"Magyar",
        "Icelandic":"Icelandic",
        "Igbo":"Igbo",
        "Indonesian":"Bahasa Indonesia",
        "Irish":"Gaeilge",
        "Italian":"Italiano",
        "Japanese":"日本語",
        "Javanese":"Jawa",
        "Kannada":"ಕನ್ನಡ",
        "Kazakh":"Қазақ",
        "Khmer":"ភាសាខ្មែរ",
        "Korean":"한국어",
        "Kurdish (Kurmanji)":"Kurdî",
        "Kyrgyz":"Кыргызча",
        "Lao":"ລາວ",
        "Latin":"Latinae",
        "Latvian":"Latvijas",
        "Lithuanian":"Lietuvos",
        "Luxembourgish":"lëtzebuergesch",
        "Macedonian":"Македонски",
        "Malagasy":"Malagasy",
        "Malay":"Malay",
        "Malayalam":"മലയാളം",
        "Maltese":"Malti",
        "Maori":"Maori",
        "Marathi":"मराठी",
        "Mongolian":"Монгол",
        "Myanmar (Burmese)":"မြန်မာ",
        "Nepali":"नेपाली",
        "Norwegian":"Norsk",
        "Pashto":"پښتو",
        "Persian":"فارسی",
        "Polish":"Polskie",
        "Portuguese":"Português",
        "Punjabi":"ਪੰਜਾਬੀ ਦੇ",
        "Romanian":"Română",
        "Russian":"русский",
        "Samoan":"Samoa",
        "Scots Gaelic":"Gàidhlig",
        "Serbian (Cyrillic)":"Српски",
        "Serbian (Latin)":"Srpski",
        "Sesotho":"Sesotho",
        "Shona":"Shona",
        "Sindhi":"سنڌي",
        "Sinhala":"සිංහල",
        "Slovak":"Slovenský",
        "Slovenian":"Slovenski",
        "Somali":"Soomaaliya",
        "Spanish":"Español",
        "Sundanese":"Sunda",
        "Swahili":"Kiswahili",
        "Swedish":"Svenska",
        "Tajik":"Тоҷикистон",
        "Tamil":"தமிழ்",
        "Telugu":"తెలుగు",
        "Thai":"ไทย",
        "Turkish":"Türk",
        "Ukrainian":"український",
        "Urdu":"اردو",
        "Uzbek":"O'zbekiston",
        "Vietnamese":"Tiếng Việt",
        "Welsh":"Cymraeg",
        "Xhosa":"isiXhosa",
        "Yiddish":"ייִדיש",
        "Yoruba":"Yorùbá",
        "Zulu":"Zulu",
    ]
    
    private var localizedLanguages: [String : String] = [
        NSLocalizedString("Afrikaans", comment: "Language"):"af",
        NSLocalizedString("Albanian", comment: "Language"):"sq",
        NSLocalizedString("Amharic", comment: "Language"):"am",
        NSLocalizedString("Arabic", comment: "Language"):"ar",
        NSLocalizedString("Armenian", comment: "Language"):"hy",
        NSLocalizedString("Azerbaijani", comment: "Language"):"az",
        NSLocalizedString("Basque", comment: "Language"):"eu",
        NSLocalizedString("Belarusian", comment: "Language"):"be",
        NSLocalizedString("Bengali", comment: "Language"):"bn",
        NSLocalizedString("Bosnian", comment: "Language"):"bs",
        NSLocalizedString("Bulgarian", comment: "Language"):"bg",
        NSLocalizedString("Catalan", comment: "Language"):"ca",
        NSLocalizedString("Cebuano", comment: "Language"):"ceb",
        NSLocalizedString("Chichewa", comment: "Language"):"ny",
        NSLocalizedString("Chinese Traditional", comment: "Language"):"zh-TW",
        NSLocalizedString("Chinese Simplified", comment: "Language"):"zh",
        NSLocalizedString("Corsican", comment: "Language"):"co",
        NSLocalizedString("Croatian", comment: "Language"):"hr",
        NSLocalizedString("Czech", comment: "Language"):"cs",
        NSLocalizedString("Danish", comment: "Language"):"da",
        NSLocalizedString("Dutch", comment: "Language"):"nl",
        NSLocalizedString("English", comment: "Language"):"en",
        NSLocalizedString("Esperanto", comment: "Language"):"eo",
        NSLocalizedString("Estonian", comment: "Language"):"et",
        NSLocalizedString("Filipino", comment: "Language"):"tl",
        NSLocalizedString("Finnish", comment: "Language"):"fi",
        NSLocalizedString("French", comment: "Language"):"fr",
        NSLocalizedString("Frisian", comment: "Language"):"fy",
        NSLocalizedString("Galician", comment: "Language"):"gl",
        NSLocalizedString("Georgian", comment: "Language"):"ka",
        NSLocalizedString("German", comment: "Language"):"de",
        NSLocalizedString("Greek", comment: "Language"):"el",
        NSLocalizedString("Gujarati", comment: "Language"):"gu",
        NSLocalizedString("Haitian Creole", comment: "Language"):"ht",
        NSLocalizedString("Hausa", comment: "Language"):"ha",
        NSLocalizedString("Hawaiian", comment: "Language"):"haw",
        NSLocalizedString("Hebrew", comment: "Language"):"iw",
        NSLocalizedString("Hindi", comment: "Language"):"hi",
        NSLocalizedString("Hmong", comment: "Language"):"hmn",
        NSLocalizedString("Hungarian", comment: "Language"):"hu",
        NSLocalizedString("Icelandic", comment: "Language"):"is",
        NSLocalizedString("Igbo", comment: "Language"):"ig",
        NSLocalizedString("Indonesian", comment: "Language"):"id",
        NSLocalizedString("Irish", comment: "Language"):"ga",
        NSLocalizedString("Italian", comment: "Language"):"it",
        NSLocalizedString("Japanese", comment: "Language"):"ja",
        NSLocalizedString("Javanese", comment: "Language"):"jw",
        NSLocalizedString("Kannada", comment: "Language"):"kn",
        NSLocalizedString("Kazakh", comment: "Language"):"kk",
        NSLocalizedString("Khmer", comment: "Language"):"km",
        NSLocalizedString("Korean", comment: "Language"):"ko",
        NSLocalizedString("Kurdish (Kurmanji)", comment: "Language"):"ku",
        NSLocalizedString("Kyrgyz", comment: "Language"):"ky",
        NSLocalizedString("Lao", comment: "Language"):"lo",
        NSLocalizedString("Latin", comment: "Language"):"la",
        NSLocalizedString("Latvian", comment: "Language"):"lv",
        NSLocalizedString("Lithuanian", comment: "Language"):"lt",
        NSLocalizedString("Luxembourgish", comment: "Language"):"lb",
        NSLocalizedString("Macedonian", comment: "Language"):"mk",
        NSLocalizedString("Malagasy", comment: "Language"):"mg",
        NSLocalizedString("Malay", comment: "Language"):"ms",
        NSLocalizedString("Malayalam", comment: "Language"):"ml",
        NSLocalizedString("Maltese", comment: "Language"):"mt",
        NSLocalizedString("Maori", comment: "Language"):"mi",
        NSLocalizedString("Marathi", comment: "Language"):"mr",
        NSLocalizedString("Mongolian", comment: "Language"):"mn",
        NSLocalizedString("Myanmar (Burmese)", comment: "Language"):"my",
        NSLocalizedString("Nepali", comment: "Language"):"ne",
        NSLocalizedString("Norwegian", comment: "Language"):"no",
        NSLocalizedString("Pashto", comment: "Language"):"ps",
        NSLocalizedString("Persian", comment: "Language"):"fa",
        NSLocalizedString("Polish", comment: "Language"):"pl",
        NSLocalizedString("Portuguese", comment: "Language"):"pt",
        NSLocalizedString("Punjabi", comment: "Language"):"pa",
        NSLocalizedString("Romanian", comment: "Language"):"ro",
        NSLocalizedString("Russian", comment: "Language"):"ru",
        NSLocalizedString("Samoan", comment: "Language"):"sm",
        NSLocalizedString("Scots Gaelic", comment: "Language"):"gd",
        NSLocalizedString("Serbian (Cyrillic)", comment: "Language"):"sr",
        NSLocalizedString("Sesotho", comment: "Language"):"st",
        NSLocalizedString("Shona", comment: "Language"):"sn",
        NSLocalizedString("Sindhi", comment: "Language"):"sd",
        NSLocalizedString("Sinhala", comment: "Language"):"si",
        NSLocalizedString("Slovak", comment: "Language"):"sk",
        NSLocalizedString("Slovenian", comment: "Language"):"sl",
        NSLocalizedString("Somali", comment: "Language"):"so",
        NSLocalizedString("Spanish", comment: "Language"):"es",
        NSLocalizedString("Sundanese", comment: "Language"):"su",
        NSLocalizedString("Swahili", comment: "Language"):"sw",
        NSLocalizedString("Swedish", comment: "Language"):"sv",
        NSLocalizedString("Tajik", comment: "Language"):"tg",
        NSLocalizedString("Tamil", comment: "Language"):"ta",
        NSLocalizedString("Telugu", comment: "Language"):"te",
        NSLocalizedString("Thai", comment: "Language"):"th",
        NSLocalizedString("Turkish", comment: "Language"):"tr",
        NSLocalizedString("Ukrainian", comment: "Language"):"uk",
        NSLocalizedString("Urdu", comment: "Language"):"ur",
        NSLocalizedString("Uzbek", comment: "Language"):"uz",
        NSLocalizedString("Vietnamese", comment: "Language"):"vi",
        NSLocalizedString("Welsh", comment: "Language"):"cy",
        NSLocalizedString("Xhosa", comment: "Language"):"xh",
        NSLocalizedString("Yiddish", comment: "Language"):"yi",
        NSLocalizedString("Yoruba", comment: "Language"):"yo",
        NSLocalizedString("Zulu", comment: "Language"):"zu"
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

    
    func getNativeLanguageName(name: String) -> String? {
        // Returns the language name given in it's OWN language
        
        let nativeName = nativeNames[name]
        if nativeName != name {
            return nativeName
        } else {
            return nil
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
            languages = google
        }
        
        var returnString = "Update language list"
        
        for item in languages {
            if item.value == code {
                returnString = item.key
            }
        }
        
        
        if CharacterSet.lowercaseLetters.contains(returnString.unicodeScalars.first!) {
            //first letter is not capital 
            // remove first letter 
            let removeIndex = returnString.index(returnString.startIndex, offsetBy: 0)
            let letterIndex = returnString.index(returnString.startIndex, offsetBy: 1)
            let char = returnString.substring(to: letterIndex)
            returnString.remove(at: removeIndex)
            returnString = "\(char.uppercased())\(returnString)"
        }
        // Handle the lowercase letters! They are messing up the sorting for some reason 
        
        return returnString

    }
    
    func codeFromLanguageName(_ name: String) -> String? {
        // Returns the language code for a given language name
        
        var returnValue: String?
        if let languageCode = localizedLanguages[name] {
            returnValue = languageCode
        }
        return returnValue
    }
    
    func initialiseLanguages() -> [Language] {
        var languages = [Language]()
        
        var fromLanguage = ""
        if var language = NSLocale.preferredLanguages.first {
            
            if language.contains("-Hans") {
                print("Language is Chinese Simplified")
                language = "zh"
            } else if language.contains("-Hant") {
                print("Language is Chinese Traditional")
                language = "zh-TW"
            } else {
                if let range = language.range(of: "-") {
                    language = language.substring(to: range.lowerBound)
                }
            }
            fromLanguage = language
        }
        
        for entry in google where entry.value != fromLanguage {
            let language = Language(
                englishName: entry.key,
                localizedName: nameFromCode(entry.value, localized: true)!,
                nativeName: getNativeLanguageName(name: entry.key),
                prefersGoogle: true,
                googleCode: entry.value,
                microsoftCode: nil)
            languages.append(language)
        }

        print("Native languages: \(nativeNames.count)")
        print("Google: \(google.count)")
        print("Localized Languages: \(localizedLanguages.count)")
        print("Initialised Languages: \(languages.count) (this should be Google - 1, because the 'from' language isn't a valid 'to' language")
        return languages
    }
}
