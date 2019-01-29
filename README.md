# Swifty Receipt Validator

[![Swift 4.2](https://img.shields.io/badge/swift-4.2-ED523F.svg?style=flat)](https://swift.org/download/)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyReceiptValidator.svg?style=flat)]()
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyReceiptValidator.svg)](https://img.shields.io/cocoapods/v/SwiftyReceiptValidator.svg)

A swift helper to handle app store receipt validation.

## Before you go live

- Test, Test, Test

Please test this properly, including production mode which will use apples production server URL. Use xcode release mode to test this to make sure everything is working. This is not something you want take lightly, triple check purchases are working when your app is in release mode.

- Your own webserver

The recommned way by apple is to use your own server and than communicate to apples server to validate the receipt.
However for obvious reason this is a hassle for alot of people like me, because I dont have a webserver and dont understand languages like PHP to make it work.

In those cases where you dont want to use your own server you can communcate directly with apples. 
Apple even has made their own in app receipt validator to show this (tutorials on ray wenderlich, in objC and a bit outdated). Doing this is apparently not very secure and therefore you should use your own server before sending stuff to apples. 

Nevertheless its still better than not doing any validation at all. I will eventually try to update this helper to include guidlines/sample code to make it work with your own server. My knowledge about server code is very basic at the moment.

https://www.raywenderlich.com/23266/in-app-purchases-in-ios-6-tutorial-consumables-and-receipt-validation

## Requirements

- iOS 10.3+
- Swift 4.2+

## Installation

[CocoaPods](https://developers.google.com/admob/ios/quick-start#streamlined_using_cocoapods) is a dependency manager for Cocoa projects. Simply install the pod by adding the following line to your pod file

```swift
pod 'SwiftyReceiptValidator'
```

There is now an [app](https://cocoapods.org/app) which makes handling pods much easier

Altenatively you can drag the swift file(s) manually into your project.

## Usage

- Add the import statement to your swift file(s) when you installed via cocoa pods

```swift
import SwiftyReceipValidator
```

- In your class with your in app purchase code create a class/strong property to SwiftyReceiptValidator

```swift
let receiptValidator = SwiftyReceiptValidator()
```

### Validate purchases

- Go to the following delegate method for the app in purchase code which you must implement for in app purchases. The method should more or less look like this

```swift
func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
      for transaction in transactions {
      
          switch transaction.transactionState {

          case .purchased:
               // Transaction is in queue, user has been charged.  Client should complete the transaction.
                
               let productIdentifier = transaction.payment.productIdentifier
               // Your code to unlock product for productIdentifier, I usually use delegation here
          
               queue.finishTransaction(transaction)
              
          case .restored:
               // Transaction was restored from user's purchase history.  Client should complete the transaction.
                
               if let productIdentifier = transaction.originalTransaction?.payment.productIdentifier {
                    // Your code to restore product for productIdentifier, I usually use delegation here
               }
         
               queue.finishTransaction(transaction)
         
         case .failed:
               ....
         }
     }
}

```

Change the purchase and restore code to look like this

```swift
case .purchased:
    // Transaction is in queue, user has been charged.  Client should complete the transaction.
      
    let productIdentifier = transaction.payment.productIdentifier
    
    receiptValidator.validate(.purchase(productId: productId), sharedSecret: nil) { result in
            defer {
                queue.finishTransaction(transaction) // make sure this is in the validation closure
            }
            
            switch result {
            case .success(let response):
              print("Receipt validation was successfull with receipt response \(response)")
              // Unlock products and/or do additional checks
            case .failure(let error, let code):
              print("Receipt validation failed with code \(code), error \(error.localizedDescription)")    
              // Maybe show alert
          }
     }
  
case .restored:
        // Transaction was restored from user's purchase history.  Client should complete the transaction.
          
        guard let productId = transaction.originalTransaction?.payment.productIdentifier else {
              queue.finishTransaction(transaction)
              return
        }
              
        receiptValidator.validate(.purchase(productId: productId), sharedSecret: nil) { result in
            defer {
                queue.finishTransaction(transaction) // make sure this is in the validation closure
            }
            
            switch result {
            case .success(let response):
                print("Receipt validation was successfull with receipt response \(response)")
                // Unlock products and/or do additional checks
            case .failure(let error, let code):
                print("Receipt validation failed with code \(code), error \(error.localizedDescription)")  
                // Maybe show alert
          }
    }
                
```

In this example sharedSecret is set to nil because I am only validating regular in app purchases. To validate an auto renewable subscriptions you can enter your shared secret that you have set up in itunes and optionally handle additional checks (see below).

### Validate subscriptions

- To validate your subscriptions simply call this method on app launch

```swift
receiptValidator.validate(.subscription, sharedSecret: "enter your secret or set to nil") { result in
    switch result {
    case .success(let response):
    print("Receipt validation was successfull with receipt response \(response)")
    // Unlock subscription features and/or do additional checks first
    case .failure(let error, let code):
        switch error {
        case .noValidSubscription:
            // no active subscription, update your cache/app etc
        default:
            break // do nothing e.g internet error or other errors
        }
    }
}
```

## StoreKit Alert Controllers and Connectivity Issues

One thing I do not know about receipt validation is if there is a way to stop the default StoreKit alert controller to show. When you get to the purchase code and to the `.purchased` switch statement, storeKit automatically shows an AlertController ("Thank you, purchase was succesfull"). This however is the point where receipt validation is actually starting so it takes another few seconds for the products to unlock. I guess this must be normal, although it would be nicer to show that alert once receipt validation is finished.

I also wonder what happens when there is server issues and receipt validation fails, because customers see the purchase succesfull alert but receipt validation has failed and therefore the products have not unlocked, yet they paid.
I assume this is a very rare case, yet I still wonder what to do in this situation. 

If anyone knows the correct way to handle this, could you please let me know.

## Final Note

As per apples guidlines you should always first connect to apples production servers and than fall back on apples sandbox servers if needed. So keep this in mind when testing in sandbox mode, validation will take a bit longer due to this.

The way this is actually done, all automatically with this helper, is that if connection to production servers fails you will get some error codes. There is an error code that tells you if you have a sandbox receipt but are using a production url. The helper uses this error code to than do the receipt validation again with the sandbox server url.

If you use your own servers than instead of directly connecting to apples server enter your server url in the enum at the top of the .swift file and than adjust the validation methods accordingly to use that enum. I dont know how to than handle the above case where your should validate with product server first and than with sandbox on your server. I also dont know if any other changes to the helper are required.

I will try to update this in the future if I have a better grasp of what is needed for your own server.
