//
//  MessageManager.swift
//  Unitrans
//
//  Created by Kim Rypstra on 22/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import Foundation
import Messages

class MessageManager: NSObject, URLSessionDelegate {

    func requestTranslation(textToTranslate: String, toCode: String, fromCode: String, google: Bool) {
        
        let sanitisedText = sanitiseEmoji(text: textToTranslate)
        getTranslation(sanitisedText, fromLanguage: fromCode, toLanguage: toCode, google: google, completion: {(translatedText) in
            if translatedText != nil {
                self.composeMessage(text: translatedText!, toCode: toCode, fromCode: fromCode, originalText: textToTranslate)
            }
        })

    }
    
    private func sanitiseEmoji(text: String) -> String {
        let characterSet = NSMutableCharacterSet(range: NSRange(location: 0x1F300, length: 0x1F700 - 0x1F300))
        var emojiPresent = false
        
        // First, split the string into characters as String (text.characters returns CharacterViews, not Strings)
        let arrayOfCharacters = text.characters
        var arrayOfCharactersAsString = [String]()
        for char in arrayOfCharacters {
            arrayOfCharactersAsString.append(String(char))
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
        var sanitised: String!
        if emojiPresent {
            let array = arrayOfCharactersAsString.flatMap { $0.characters }
            sanitised = String(array)
        } else {
            sanitised = text
        }
        
        return sanitised

    }

    
    private func composeMessage(text: String, toCode: String, fromCode: String, originalText: String) {
        let message: MSMessage? = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = text
        
        // text is already encoded as it's been received from the server
        var baseURL = URLComponents(string: "http://www.disordersoftware.com/message")
        baseURL?.query = "text=\(text)&from=\(fromCode)&to=\(toCode)&original=\(originalText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)"
        message?.url = baseURL?.url
        message?.layout = layout
        
        if message != nil {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "COMPOSED_MESSAGE"), object: nil, userInfo: ["Message" : message! as MSMessage]))
        }
        
    }
    
    func abortWithError(error: String, code: Int) {
        let errorPost = DSError(domain: error, code: code)
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":errorPost]))
    }
    
    func getTranslation(_ text: String, fromLanguage: String, toLanguage: String, google: Bool, completion: @escaping (String?) -> ()) {
        let baseURL = "http://api.disordersoftware.com/unitrans/Testing/api2.php?action=translate"

        // Set up the payload
        let textToTranslate = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let fromLanguage = fromLanguage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let toLanguage = toLanguage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        // Set up the URL String
        var urlString = ""
        if textToTranslate != nil && fromLanguage != nil && toLanguage != nil {
            urlString = baseURL + "&text=\(textToTranslate!)&from=\(fromLanguage!)&to=\(toLanguage!)&v=g"
        }
        
        guard let url = URL(string: urlString)
            else {
                print("Error 1")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Unable to compose message", code: 1)]))
                completion(nil)
                return
        }
        
        // Set up the request
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        var dataTask = URLSessionDataTask()
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        // Debug
        print(urlString)
        
        
        // Send the request
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                print("An error may have occurred")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error": DSError(domain: error!.localizedDescription, code: 0)]))
                completion(nil)
                
            } else {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode != 200 {
                    print("Error - server returned \(httpResponse.statusCode)")
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error": DSError(domain: "Unable to reach server. Status: \(httpResponse.statusCode)", code: 0)]))
                    completion(nil)
                } else {
                    do {
                        if data != nil {
                            if google {
                                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                                //print(json)
                                guard let dataLevel = json["data"] as? NSDictionary else {
                                    self.abortWithError(error: "JSON Error", code: 1)
                                    return
                                }
                                guard let translationsLevel = dataLevel["translations"] as? NSArray else {
                                    self.abortWithError(error: "JSON Error", code: 2)
                                    return
                                }
                                guard let text = translationsLevel[0] as? NSDictionary else {
                                    self.abortWithError(error: "JSON Error", code: 3)
                                    return
                                }
                                print(text["translatedText"]!)
                                completion(text["translatedText"] as! String)
                            }
                        }
                    } catch let error {
                        print("Error decoding JSON: \(error)")
                        completion(nil)
                    }
                }
            }
        })
        
        dataTask.resume()
    }

}
