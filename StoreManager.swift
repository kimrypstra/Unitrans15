//
//  StoreManager.swift
//  Unitrans
//
//  Created by Kim Rypstra on 12/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit
import StoreKit

extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Date.iso8601Formatter.date(from: self)
    }
}

class StoreManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate, URLSessionDelegate, SKRequestDelegate {

    let productIdentifiers = Set(["com.kimrypstra.unitrans.MessagesExtension.UnitransIAP2"])
    var product: SKProduct?
    
    
    
// MARK ----------------- PRODUCT LIST ---------------------------
    
    
    
    func updateProductList() {
        // Check iTunes Connect for updated product details
        SKPaymentQueue.default().add(self)
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        
        
        
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            NSLog("**** Received \(response.products.count) products and \(response.invalidProductIdentifiers.count) invalid products")
            product = response.products.first
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didReceiveProductData"), object: nil, userInfo: ["product":response.products.first!]))
        } else {
            NSLog("**** Invalid products: \(response.invalidProductIdentifiers)")
        }
    }
    
    
    
    
    
    
    
    
// MARK ------------------- PURCHASING -----------------------
    
    
    
    
    
    
    func buyTheThing() {
        // Buy the stuff
        if product != nil && SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product!)
            if payment != nil {
                SKPaymentQueue.default().add(payment)
            } else {
                NSLog("**** Can't form payment")
            }
            
        } else if product == nil {
            NSLog("**** Product not ready yet")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error purchasing", code: 0)]))
        } else if !SKPaymentQueue.canMakePayments() {
            NSLog("**** Can't make payments")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: NSLocalizedString("Unable to make payments", comment: "Presented when the user is not able to make payments from this device"), code: 0)]))
        } else {
            // some generic error 
            NSLog("**** Error making purchase")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error purchasing", code: 1)]))
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        NSLog("**** updatedTransactions")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                NSLog("**** Success")
                deliverTheGoods()
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                SKPaymentQueue.default().finishTransaction(transaction as SKPaymentTransaction)
            case .purchasing:
                NSLog("**** Purchasing...")
                break
            case .failed:
                NSLog("**** Failed - \(transactions.first?.error)")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                let error = DSError(domain: (transactions.first?.error?.localizedDescription)!, code: 3)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":error]))
                SKPaymentQueue.default().finishTransaction(transaction)
            //
            case .restored:
                NSLog("**** Restored!")
                NSLog("**** Product Identifier: \(transaction.original?.payment.productIdentifier)")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                deliverTheGoods()
                
            //
            case .deferred:
                NSLog("**** Deferred...")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: NSLocalizedString("Purchase deferred", comment: "Presented when a purchase is put on hold, waiting for some other action - eg, approval from a parent"), code: 0)]))
                //
            }
        }
        
    }
    
    
    
    
    
// MARK ----------- RESTORATION ---------------------------------
    
    
    
    
    
    /*
    func sendReceiptForDecoding(receiptString: String) {
        guard let url = URL(string: "http://api.disordersoftware.com/unitrans/validate.php") else {
            NSLog("**** URL Error in receipt validation")
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        var dataTask = URLSessionDataTask()
        var request = URLRequest(url: url)
        request.httpBody = receiptString.data(using: String.Encoding.ascii)
        request.httpMethod = "POST"
        
        NSLog("**** Sending validation request to \(url.absoluteString)")
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error == nil {
                do {
                    NSLog("**** Received: \(data!)")
                    let payload = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                    //NSLog("**** Payload: \(payload)")
                    // now, parse the payload and handle the codes and check the things
                    if let response = payload["Response"] as? [String: Any] {
                        if response["status"] as? Int == 0 {
                            NSLog("**** All is well")
                            let receipt = response["receipt"] as! [String: Any]
                            if receipt != nil {
                                print(receipt)
                                if let version = receipt["original_application_version"] as? String {
                                    let versionDouble = Double(version)
                                    NSLog("**** Purchased at version \(versionDouble). Restore.")
                                    self.deliverTheGoods()
                                }
                            }
                        } else {
                            
                        }
                    }
                } catch {
                    NSLog("**** Error deserializing: \(error)")
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 0)]))
                }
            } else {
                let httpResponse = response as! HTTPURLResponse
                NSLog("**** Status: \(httpResponse.statusCode) \nError: \(error)")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 1)]))
            }
        })
        
        dataTask.resume()
    }
    */
    
    func restorePurchases() {
        NSLog("**** Restoring purchases...")
        
        SKPaymentQueue.default().restoreCompletedTransactions()
        
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            let receiptData = NSData(contentsOf: receiptURL)
            //let receiptString = receiptData?.base64EncodedString(options: .init(rawValue: 0))
            if receiptData == nil {
                NSLog("**** There is no receipt at: \(receiptURL.absoluteString)")
                //there is no receipt; refresh
                let refreshRequest = SKReceiptRefreshRequest()
                refreshRequest.start()
                refreshRequest.delegate = self
                // see requestDidFinish for results
            } else {
                //send to server for forwarding to apple -- Nope!
                //sendReceiptForDecoding(receiptString: receiptString!)
                
                // If there is a receipt, just give the stuff. We'll implement version checking and receipt validation later on. 
                NSLog("**** Got a receipt!")
                deliverTheGoods()
            }
        } else {
            // No receipt URL in bundle; refresh.
            NSLog("**** There is no receipt in the bundle")
            let refreshRequest = SKReceiptRefreshRequest()
            refreshRequest.start()
            refreshRequest.delegate = self

        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        NSLog("** Finished request...")
        
        if request.isKind(of: SKReceiptRefreshRequest.self) {
            NSLog("** Receipt refresh complete")
            if let receiptURL = Bundle.main.appStoreReceiptURL {
                let receiptData = NSData(contentsOf: receiptURL)
                let receiptString = receiptData?.base64EncodedString(options: .init(rawValue: 0))
                if receiptData == nil {
                    NSLog("** There is no receipt at: \(receiptURL.absoluteString)")
                    //there is no receipt
                    NSLog("**** No receipt to refresh")
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 3)]))
                } else {
                    //send to server for forwarding to apple
                    //sendReceiptForDecoding(receiptString: receiptString!)
                    // actually don't worry about it yet 
                    
                    deliverTheGoods()
                    
                }
            } else {
                NSLog("** No receipt found in bundle, and no receipt found after refresh.")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 2)]))
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 5)]))
        NSLog("**** Request failed with error: \(error)")
    }
    
    
    
    
    
    
    
// MARK -------------- DELIVERY -----------------------------------
    
    
    
    
    
    func deliverTheGoods() {
        // Make the changes to UserDefaults to reflect the purchase and trigger a refresh of the app to take into account the changes immediately
        let defaults = UserDefaults()
        defaults.setValue(true, forKey: "subscribed")
        
        // Send a notification to update the store UI
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REFRESH_UI"), object: nil, userInfo: nil))
    }
}
