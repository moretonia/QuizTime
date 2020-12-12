//
//  IAPHandler.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 05/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import StoreKit
import ORCommonCode_Swift

enum IAPHandlerAlertType {
    case disabled
    case restored
    case purchased
    case error
    case failed
    
    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        case .error: return "Purchase doesn't exist"
        case .failed: return "Purchasing failed"
        }
    }
}

struct ProductInfo {
    var productId: String
    var themeName: String?
    var priceWithCurrency: String?
    var triplePriceWithCurrency: String?
}

class IAPHandler: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    fileprivate var productsInfo = [ProductInfo]()
    
    static var shared = IAPHandler()
    
    private let packProductId: String = "themes_pack"
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseProduct(with productId: String) {
        if iapProducts.count == 0 {
            notifyAboutPurchasing(.error, productsId: [])
            return
        }
        
        let index = iapProducts.firstIndex { (product) -> Bool in
            return product.productIdentifier == productId
        }
        
        if self.canMakePurchases() {
            if let strongIndex = index {
                let product = iapProducts[strongIndex]
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
                
                print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
                productID = product.productIdentifier
            } else {
                notifyAboutPurchasing(.error, productsId: [])
            }
        } else {
            notifyAboutPurchasing(.disabled, productsId: [])
        }
    }
    
    func purchaseTheme(with name: String) {
        let productId = self.productId(by: name)
        purchaseProduct(with: productId)
    }
    
    func buyPack() {
        let productId = self.packProductId
        purchaseProduct(with: productId)
    }
    
    func productIdentifiers() -> Set<String> {
        guard let themes = Theme.mr_findAll() as? [Theme] else {
            return []
        }
        
        var identifiers = themes.map { (theme) -> String in
            return productId(by: theme.name!)
        }
        
        var productsInfo = themes.map { (theme) -> ProductInfo in
            return ProductInfo(productId: productId(by: theme.name!), themeName: theme.name!, priceWithCurrency: nil, triplePriceWithCurrency: nil)
        }
        
        let packInfo = ProductInfo(productId: packProductId, themeName: nil, priceWithCurrency: nil, triplePriceWithCurrency: nil)
        productsInfo.append(packInfo)
        identifiers.append(packProductId)
        
        self.productsInfo = productsInfo
        
        return Set(identifiers)
    }
    
    fileprivate func productId(by name: String) -> String {
        return (Constants.purchaseThemePrefix + name).lowercased()
    }
    
    fileprivate func productIndex(with productId: String) -> Int? {
        let index = productsInfo.firstIndex(where: { (info) -> Bool in
            return info.productId == productId
        })
        
        return index
    }
    
    fileprivate func notifyAboutPurchasing(_ status: IAPHandlerAlertType, productsId: [String]) {
        var userInfo = [AnyHashable : Any]()
        
        var products = [ProductInfo]()
        
        var themeNames = [String]()
        
        for productId in productsId {
            guard let index = productIndex(with: productId) else {
                continue
            }
            
            let productInfo = productsInfo[index]
            
            if let themeName = productInfo.themeName {
                themeNames.append(themeName)
            }
            
            products.append(productInfo)
        }
        
        userInfo[Constants.purchaseStatus] = status
        userInfo[Constants.purchasesInfo] = products
        
        or_postNotification(Notifications.iApProductPurchased, object: self, userInfo: userInfo)
    }
    
    fileprivate func notifyAboutFetching() {
        let userInfo: [AnyHashable : Any] = [Constants.purchasesInfo: productsInfo]
        
        or_postNotification(Notifications.iApProductsFetched, object: self, userInfo: userInfo)
    }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        
        let productIdentifiers = self.productIdentifiers()
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts {
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currencyAccounting
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                let triplePrice = numberFormatter.string(from: NSDecimalNumber(value: product.price.doubleValue * 3.0))
                
                if let index = productIndex(with: product.productIdentifier) {
                    productsInfo[index].priceWithCurrency = price1Str
                    productsInfo[index].triplePriceWithCurrency = triplePrice
                }
            }
        }
        
        for invalidId in response.invalidProductIdentifiers {
            if let index = productIndex(with: invalidId) {
                productsInfo.remove(at: index)
            }
        }
        
        notifyAboutFetching()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var productsId = [String]()
        
        for transaction in queue.transactions {
            productsId.append(transaction.payment.productIdentifier)
        }
        notifyAboutPurchasing(.restored, productsId: productsId)
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        notifyAboutPurchasing(.failed, productsId: [])
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    notifyAboutPurchasing(.purchased, productsId: [trans.payment.productIdentifier])
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    notifyAboutPurchasing(.failed, productsId: [trans.payment.productIdentifier])
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    notifyAboutPurchasing(.restored, productsId: [trans.payment.productIdentifier])
                default: break
                }
            }
        }
    }
}
