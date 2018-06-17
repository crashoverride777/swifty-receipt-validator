# Swifty Receipt Validator

[![Swift 4.1](https://img.shields.io/badge/swift-4.1-ED523F.svg?style=flat)](https://swift.org/download/)
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

## Default validation checks

By default this helper will validate a receipt based on these checks

- Fetching the app store receipt stored in the apps main bundle. If it fails 1st time it will try to request a new receipt, if it fails again receipt validation will fail.
- Check for valid receipt status code
- Check receipt send for verification exists in json response
- Check receipt contains correct bundle id for app
- Check receipt contains product id for app

## Requirements

- iOS 9.3+
- Swift 4.0+

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
    
    receiptValidator.validate(productIdentifier, sharedSecret: nil) { result in
          switch result {
          
          case .success(let data):
              print("Receipt validation was successfull with data \(data)")
              // Unlock products and/or do additional checks
          
          case .failure(let code, let error):
              print("Receipt validation failed with code \(code), error \(error.localizedDescription)")    
              // Maybe show alert
          }
          
          queue.finishTransaction(transaction) // make sure this is in the validation closure
     }
  
case .restored:
        // Transaction was restored from user's purchase history.  Client should complete the transaction.
          
        if let productIdentifier = transaction.originalTransaction?.payment.productIdentifier {      
              
              receiptValidator.validate(productIdentifier, sharedSecret: nil) { result in
                  switch result {
                 
                  case .success(let data):
                        print("Receipt validation was successfull with data \(data)")
                        // Unlock products and/or do additional checks
                        
                  case .failure(let code, let error):
                        print("Receipt validation failed with code \(code), error \(error.localizedDescription)")  
                        // Maybe show alert
                  }
      
                  queue.finishTransaction(transaction) // make sure this is in the validation closure
             }
        }
                
```

In this example sharedSecret is set to nil because I am only validating regular in app purchases. To validate an auto renewable subscriptions you can enter your shared secret that you have set up in itunes and optionally handle additional checks (see below).

## Additional Validation Checks

If you would like to handle additional validation checks you can use the response (optional dictionary) that is returned in the success case of the result enum. Use the 4 keys in the ResponseKey enum to access the inital parts of the reponse. 

e.g 

```swift
receiptValidator.validate(productIdentifier, sharedSecret: "") { result in
         case .success(let data):
         
              // example 1
              let receiptKey = SwiftyReceiptValidator.ResponseKey.receipt.rawValue
              if let receipt = data[receiptKey] {
                     // do something
                 
              }
              
              // example 2 (auto-renewable subscriptions)
              let receiptInfoFieldKey = SwiftyReceiptValidator.ResponseKey.receipt_info_field.rawValue
              if let receipt = data[receiptInfoFieldKey] {
                     // do something
              }
             
           ....        
    
}
```

You than can use the InfoKey enum keys to get specific values e.g expiry date, app bundle ID etc. 

e.g 

```swift
....
if let receipt = data[receiptKey] {
     // example 1
     let creationDateKey = SwiftyReceiptValidator.InfoKey.creation_date.rawValue
     if let creationDate = receipt[creationDateKey] as? ... {
          ...
     }
     
     // example 2
     let inAppKey = SwiftyReceiptValidator.InfoKey.in_app.rawValue
     if let inApp = receipt[inAppKey] as? [AnyObject] {
         
         for receiptInApp in inApp {
            let expiryDateKey = SwiftyReceiptValidator.InfoKey.InApp.expires_date.rawValue
            if let expiryDate = receiptInApp[expiryDateKey] as? ... {
              ...
        }
    }
}

/// Unlock your products when abo 
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
