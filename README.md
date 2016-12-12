# Swifty Receipt Validator

A swift helper to handle app store receipt validation.

I am by no means an expert, as receipt validation was causing me headaches for months. I however believe I am on the right track with this helper. 
The most important part for me is feedback of any kind, especially by people that have a better knowledge about it than me. So please dont hestitate to open an issue or email me, this way we can make sure this helper is as solid as it can be.

There are some helpers on gitHub that I got inspired by, but I didnt like how the code was either outdated, didnt follow all of apples guidlines, were not very swift like or unsafe due things such as force unwrapping. 


# Validation Checks

By default this helper will validate a receipt based on these checks

1) Fetching the app store receipt stored in the apps main bundle. If it fails 1st time it will try to request a new receipt, if it fails again receipt validation will fail.

2) Check for valid receipt status code

3) Check receipt send for verification exists in json response

4) Check receipt contains correct bundle id for app

5) Check receipt contains product id for app

You can also handle additional checks, see below

# Cocoa Pods

I know that the current way of copying the .swift file(s) into your project sucks and is bad practice, so I am working hard to finally support CocoaPods very soon. Stay tuned.

In the meantime I would create a folder on your Mac, called something like SharedFiles, and drag the swift file(s) into this folder. Than drag the files from this folder into your project, making sure that "copy if needed" is not selected. This way its easier to update the files and to share them between projects.

# Before you go live

- Test, Test, Test

Please test this properly, including production mode which will use apples production server URL. Use xcode release mode to test this to make sure everything is working. This is not something you want take lightly, triple check purchases are working when your app is in release mode.

- Your own webserver

The recommned way by apple is to use your own server and than communicate to apples server to validate the receipt.
However for obvious reason this is a hassle for alot of people like me, because I dont have a webserver and dont understand languages like PHP to make it work.

In those cases where you dont want to use your own server you can communcate directly with apples. 
Apple even has made their own in app receipt validator to show this (tutorials on ray wenderlich, in objC and a bit outdated). Doing this is apparently not very secure and therefore you should use your own server before sending stuff to apples. 

Nevertheless its still better than not doing any validation at all. I will eventually try to update this helper to include guidlines/sample code to make it work with your own server. My knowledge about server code is very basic at the moment.

https://www.raywenderlich.com/23266/in-app-purchases-in-ios-6-tutorial-consumables-and-receipt-validation

# Set-Up

- Add the following files to your project

1) SwiftyReceipValidator.swift

2) SwiftyReceiptObtainer.swift

# How to use

In your in app purchase code go to the method

```swift
func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) { ....
```

where the code should look more or less like this

```swift
for transaction in transactions {
      switch transaction.transactionState {


     case .purchased:
          // Transaction is in queue, user has been charged.  Client should complete the transaction.
                
          let productID = transaction.payment.productIdentifier
          /// Your code to unlock product for productID, I usually use delegation here
          
          queue.finishTransaction(transaction)
              
     case .restored:
          // Transaction was restored from user's purchase history.  Client should complete the transaction.
                
          if let productID = transaction.originalTransaction?.payment.productIdentifier {
               /// Your code to restore product for productID, I usually use delegation here
          }
         
          queue.finishTransaction(transaction)
         
    case .failed:
         ....
    }
    
    ....
}
```

Change the purchase and restore code to look something like this

```swift
case .purchased:
    // Transaction is in queue, user has been charged.  Client should complete the transaction.
      
    let productID = transaction.payment.productIdentifier
    SwiftyReceipValidator.validate(forProductID: productID, sharedSecret: nil) { (success, response) in
          if success {
              /// Your code to unlock product for productID, I usually use delegation here
          } else {
              /// maybe show alert here
          }          
          
          queue.finishTransaction(transaction)
     }
  
case .restored:
        // Transaction was restored from user's purchase history.  Client should complete the transaction.
          
        if let productID = transaction.originalTransaction?.payment.productIdentifier {      
              SwiftyReceipValidator.validate(forProductID: productID, sharedSecret: nil) { (success, response) in
                    if success {
                       /// Your code to restore product for productID, I usually use delegation here
                    } else {
                       /// maybe show alert 
                    }
                    
                    queue.finishTransaction(transaction)
              }
        }
                
```

In this example sharedSecret is set to nil because I am only validating regular in app purchases. To validate a auto renewable subscriptions you can enter your shared secret that you have set up in itunes and optionally handle additional checks (see below).

# Additional Validation Checks

If you would like to handle additional validation checks you can use the response (optional dictionary) that is returned in the completion handler. Use the 4 keys in the ResponseKey enum to access the inital parts of the reponse. 

e.g 

```swift
SwiftyReceipValidator.validate(forProductID: productID, sharedSecret: "") { (success, response) in
         if success {
         
              // example 1
              let receiptKey = SwiftyReceipValidator.ResponseKey.receipt.rawValue
              if let receipt = response[receiptKey] {
                     // do something
                 
              }
              
              // example 2 (auto-renewable subscriptions)
              let receiptInfoFieldKey = SwiftyReceipValidator.ResponseKey.receipt_info_field.rawValue
              if let receipt = response[receiptInfoFieldKey] {
                     // do something
              }
              
 
              
        } else {
           ....        
        }
        
        queue.finishTransaction(transaction)
}
```

You than can use the InfoKey enum keys to get specific values e.g expiry date, app bundle ID etc. 

e.g 

```swift
....
if let receipt = response[receiptKey] {
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

# StoreKit Alert Controllers and Connectivity Issues

One thing I do not know about receipt validation is if there is a way to stop the default StoreKit alert controller to show. When you get to the purchase code and to the .Purchased switch statement, storeKit automatically shows an AlertController ("Thank you, purchase was succesfull"). This however is the point where receipt validation is actually starting so it takes another few seconds for the products to unlock. I guess this must be normal, although it would be nicer to show that alert once receipt validation is finished.

I also wonder what happens when there is server issues and receipt validation fails, because customers see the purchase succesfull alert but receipt validation has failed and therefore the products have not unlocked, yet they paid.
I assume this is a very rare case, yet I still wonder what to do in this situation. 

If anyone knows the correct way to handle this, could you please let me know.

# Final Note

As per apples guidlines you should always first connect to apples production servers and than fall back on apples sandbox servers if needed. So keep this in mind when testing in sandbox mode, validation will take a bit longer due to this.

The way this is actually done, all automatically with this helper, is that if connection to production servers fails you will get some error codes. There is an error code that tells you if you have a sandbox receipt but are using a production url. The helper uses this error code to than do the receipt validation again with the sandbox server url.

If you use your own servers than instead of directly connecting to apples server enter your server url in the enum at the top of the .swift file and than adjust the validation methods accordingly to use that enum. I dont know how to than handle the above case where your should validate with product server first and than with sandbox on your server. I also dont know if any other changes to the helper are required.

I will try to update this in the future if I have a better grasp of what is needed for your own server.

# Release notes

- v2.1

Added support for auto-renewable subscriptions

Validation method now returns the response so you can do additional validation checks if needed

Changed the API to make it more readable. Please read the instructions again. 

- v2.0.1

Completion handler now returns on main queue so you dont have to do it your self in the closure.

- v2.0

Project has been renamed to SwiftyReceiptValidator

No more source breaking changes after this update. All future changes will be handled with deprecated messages unless the whole API changes.
