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

    let productIdentifiers = Set(["com.kimrypstra.unitrans.MessagesExtension.Yearly"])
    var product: SKProduct?
    var errorReachingStore = false
    
    func updateProductList() {
        // Check iTunes Connect for updated product details
        SKPaymentQueue.default().add(self)
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        } else {
            print("Can't make payments")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: NSLocalizedString("Unable to make payments", comment: "Presented when the user is not able to make payments from this device"), code: 0)]))
            
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            print("Received \(response.products.count) products and \(response.invalidProductIdentifiers.count) invalid products")
            product = response.products.first
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didReceiveProductData"), object: nil, userInfo: ["product":response.products.first!]))
        } else {
            print("Invalid products: \(response.invalidProductIdentifiers)")
        }

    }
    
    func buyTheThing() {
        print("BUYBUYBUY!")
        // Buy the stuff
        if product != nil && !errorReachingStore {
            let payment = SKPayment(product: product!)
            SKPaymentQueue.default().add(payment)
            
            
            
        } else {
            print("Product not ready yet")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error purchasing", code: 0)]))
        }
        
    }
    
    
    
    func restorePurchases() {
        print("Restoring purchases...")
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            
            let receiptData = NSData(contentsOf: receiptURL)
            let receiptString = receiptData?.base64EncodedString(options: .init(rawValue: 0))
            if receiptData == nil {
                print("There is no receipt at: \(receiptURL.absoluteString)")
                //there is no receipt
                let refreshRequest = SKReceiptRefreshRequest()
                refreshRequest.start()
                refreshRequest.delegate = self
                // When the refresh request is complete, requestDidFinish is called and this method is called again
            } else {
                //send to server for forwarding to apple 

                guard let url = URL(string: "http://api.disordersoftware.com/unitrans/validate.php") else {
                    print("URL Error in receipt validation")
                    return
                }
                let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
                
                var dataTask = URLSessionDataTask()
                var request = URLRequest(url: url)
                request.httpBody = receiptString?.data(using: String.Encoding.ascii)
                request.httpMethod = "POST"
                
                print("Sending validation request to \(url.absoluteString)")
                dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    if error == nil {
                        do {
                            print("Received: \(data!)")
                            let payload = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                            //print("Payload: \(payload)")
                            // now, parse the payload and handle the codes and check the things 
                            if let response = payload["Response"] as? [String: Any] {
                                if response["status"] as? Int == 0 {
                                    print("All is well")
                                    let receipt = response["receipt"] as! [String: Any]
                                    if receipt != nil {
                                        print(receipt)
                                        if let version = receipt["original_application_version"] as? String {
                                            let versionDouble = Double(version)
                                            if versionDouble! <= 1.2 {
                                                print("Version is <= 1.2; Give all of the things")
                                                self.deliverTheGoods(transaction: nil)
                                            } else {
                                                print("Version is >= 1.2; continue validating")
                                                // This receipt was generated after the business model changed - it is for an IAP, not an outright.
                                                // So, we need to check that it is current, or if the subscription has been cancelled
                                                // check 'expires_date' and 'cancellation_date' 
                                                
                                                if receipt["cancellation_date"] != nil {
                                                    // the thing is cancelled, don't give the things
                                                } else if let expiryDate = receipt["expires_date"] as? String {
                                                    let date = expiryDate.dateFromISO8601
                                                    if date! < Date() {
                                                        // The thing is expired; don't give the things
                                                    } else {
                                                        // Give the things!! 
                                                        self.deliverTheGoods(transaction: nil)
                                                    }
                                                } else {
                                                    // something is amiss here
                                                }
                                                
                                            
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }
                        } catch {
                            print("Error deserializing: \(error)")
                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 0)]))
                        }
                    } else {
                        let httpResponse = response as! HTTPURLResponse
                        print("Status: \(httpResponse.statusCode) \nError: \(error)")
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 1)]))
                    }
                })
                
                dataTask.resume()
            }
            
        } else {
            print("No receipt in bundle?")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 2)]))
        }

    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("Finished request...")
        
        if request.isKind(of: SKReceiptRefreshRequest.self) {
            restorePurchases()
        }
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: "Error restoring purchases", code: 5)]))
        print("Request failed with error: \(error)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("updatedTransactions")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Success! Making money!
                print("Success")
                
                deliverTheGoods(transaction: transaction)
            case .purchasing:
                print("Purchasing...")
                break
            case .failed:
                print("Failed - \(transactions.first?.error)")
                errorReachingStore = true
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                let error = DSError(domain: (transactions.first?.error?.localizedDescription)!, code: 3)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":error]))
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                
            //
            case .restored:
                print("Restored!")
                deliverTheGoods(transaction: transaction)
                
            //
            case .deferred:
                print("Deferred...")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":DSError(domain: NSLocalizedString("Purchase deferred", comment: "Presented when a purchase is put on hold, waiting for some other action - eg, approval from a parent"), code: 0)]))
                //
            }
        }
        
    }
    
    func deliverTheGoods(transaction: SKPaymentTransaction?) {
        // Make the changes to UserDefaults to reflect the purchase and trigger a refresh of the app to take into account the changes immediately
        let defaults = UserDefaults()
        if (defaults.value(forKey: "subscribed") == nil) {
            defaults.setValue(true, forKey: "subscribed")
        }
        
        // Send a notification to update the store UI
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REFRESH_UI"), object: nil, userInfo: nil))
        
        // Finish the transaction
        if transaction != nil {
            SKPaymentQueue.default().finishTransaction(transaction!)
            SKPaymentQueue.default().remove(self)
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "REMOVE_BLUR")))
        

    }
}
