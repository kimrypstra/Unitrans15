//
//  StoreManager.swift
//  Unitrans
//
//  Created by Kim Rypstra on 12/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit
import StoreKit

class StoreManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    let productIdentifiers = Set(["com.kimrypstra.unitrans.MessagesExtension.Yearly"])
    var product: SKProduct?
    
    func updateProductList() {
        // Check iTunes Connect for updated product details
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        } else {
            print("Can't make payments")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // handle the updated list of products, and populate the stackView with your XIBs 
        if response.products.count > 0 {
            print("Received \(response.products.count) products and \(response.invalidProductIdentifiers.count) invalid products")
            product = response.products.first
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didReceiveProductData"), object: nil, userInfo: ["product":response.products.first]))
        } else {
            print("Invalid products: \(response.invalidProductIdentifiers)")
        }

    }
    
    func buyTheThing() {
        print("BUYBUYBUY!")
        // Buy the stuff
        if product != nil {
            let payment = SKPayment(product: product!)
            SKPaymentQueue.default().add(payment)
        } else {
            print("Product not ready yet")
        }
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // check if the payment was successful, etc...
        switch transactions.first!.transactionState {
        case .purchased:
            // Success! Making money! 
            print("Success")
            deliverTheGoods()
        case .purchasing:
            print("Purchasing...")
            // 
        case .failed:
            print("Failed - \(transactions.first?.error)")
            let error = DSError(domain: (transactions.first?.error?.localizedDescription)!, code: 0)
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ERROR"), object: nil, userInfo: ["error":error]))
            
            //
        case .restored:
            print("Restored!")
            if transactions.first?.original?.payment.productIdentifier == productIdentifiers.first {
                deliverTheGoods()
            }
            //
        case .deferred:
            print("Deferred...")
            //
        }
    }
    
    func deliverTheGoods() {
        // Make the changes to UserDefaults to reflect the purchase and trigger a refresh of the app to take into account the changes immediately
        let defaults = UserDefaults()
        if (defaults.value(forKey: "subscribed") == nil) {
            defaults.setValue(true, forKey: "subscribed")
        }
    }
    
    func validateReciept() {
        // This is a placeholder to remind you to validate reciepts. You'll need to change the name of the function too you silly bastard.
    }
    
}
