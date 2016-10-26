//
//  ConnectionManager.swift
//  UniversalTranslator
//
//  Created by Kim Rypstra on 20/07/2016.
//  Copyright © 2016 Kim Rypstra. All rights reserved.

import Foundation

class ConnectionManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    /*
    This needs to be updated with the following capabilities: 
    - Reachability
    - Detect the whether the returned text is from Google or Microsoft (the actual routing will be done server-side
    */
    
    
    private let baseURL = "http://api.disordersoftware.com/unitrans/api.php?action=translate"

    func getTranslation(_ text: String, fromLanguage: String, toLanguage: String) -> String? {
        // An NSDictionary to return
        var dict = NSDictionary()
        
        // Set up the payload
        let textToTranslate = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let fromLanguage = fromLanguage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let toLanguage = toLanguage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // Set up the URL String
        var urlString = ""
        if textToTranslate != nil && fromLanguage != nil && toLanguage != nil {
            urlString = baseURL + "&text=\(textToTranslate!)&from=\(fromLanguage!)&to=\(toLanguage!)&v=2"
        }
        
        guard let url = URL(string: urlString)
            else {
                print("Error 1")
                return nil
            }
        
        // Set up the request
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        var dataTask = URLSessionDataTask()
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        // Send the request
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                print("Error: \(error)")
                return nil
                
            } else {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode != 200 {
                    //print("Error - server returned \(httpResponse.statusCode)")
                    return nil
                } else {
                    do {
                        if data != nil {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                            dict = json
                            if let translatedText = dict["0"] as! String? {
                                return translatedText
                            }
                            
                        }
                    } catch let error {
                        print("Error decoding JSON")
                        return nil
                    }
                }
            }
        })
        
        dataTask.resume()
    }
}
