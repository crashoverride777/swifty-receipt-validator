# Swift App Store Receipt Validator

A swift protocol extension to handle app store receipt validation.

I am by no means an expert, as receipt validation was causing me headaches for months. I however believe I am on the right track with this helper. 

The most important part for me is feedback of any kind, especially by people that have a better knowledge about it than me. So please dont hestitate to open an issue or email me, this way we can make sure this helper is as solid as it can be.

There are some helpers on gitHub that I got inspired by, but I didnt like how the code was either outdated, didnt follow all of apples guidlines, were not very swift like or unsafe due things such as force unwrapping. 

I tried to follow apples guidlines as well as I can, e.g when fetching the app store receipt stored in your apps main bundle you should request a new receipt incase getting it the 1st time failes, if it than fails again validation should also fail. 

I am doing the following validation checks, if the JSON response returns a valid receipt status code.

1) Check receipt send for verification exists in json response

2) Check receipt contains correct bundle id for app

3) Check receipt contains product id for app

# Before you go live

- Test, Test, Test

Please test this properly, including production mode which will use apples production server URL. Use xcode release mode to test this to make sure everything is working. This is not something you want take lightly, triple check purchases are working where your app is in release mode.

- Your own webserver

The recommned way by apple is to use your own server and than communicate to apples server to validate the receipt.
However for obvious reason this is a hassle for alot of people like me, because I dont have a webserver and dont understand languages like PHP to make it work.

In those cases where you dont want to use your own server you can communcate directly with apples. 
Apple even has made their own in app receipt validator to show this (tutorials on ray wenderlich, in objC and a bit outdated). Doing this is apparently not very secure and therefore you should use your own server before sending stuff to apples. 

Nevertheless its still better than not doing any validation at all. I will eventually try to update this helper to include guidlines/sample code to make it work with your own server. My knowledge about server code is very basic at the moment.

https://www.raywenderlich.com/23266/in-app-purchases-in-ios-6-tutorial-consumables-and-receipt-validation

# Set-Up

- Add the following files to your project

1) AppStoreReceipValidator.swift

2) AppStoreReceiptObtainer.swift

# How to use

In your in app purchase code go the method

```swift
func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) { ....
```

where you should have these to enums to handle app purchases and restores. The code should look more or less like this

```swift
for transaction in transactions {
      switch transaction.transactionState {


     case .Purchased:
          // Transaction is in queue, user has been charged.  Client should complete the transaction.
                
          let transactionID = transaction.payment.productIdentifier
          /// Your code to unlock product for transactionID, I usually use delegation here
          
          queue.finishTransaction(transaction)
              
     case .Restored:
          // Transaction was restored from user's purchase history.  Client should complete the transaction.
                
          if let originalTransactionID = transaction.originalTransaction?.payment.productIdentifier {
               /// Your code to restore product for originalTransactionID, I usually use delegation here
          }
         
          queue.finishTransaction(transaction)
         
    case .Failed:
         ....
    }
    
    ....
}
```

To use the receipt validator go the the class or class extension that has your in app purchase code with the above method. Go to where you added the SKPaymentTransactionObserver and confirm to the AppStoreReceiptValidator protocol as well

```swift
class SomeClass: ... , SKPaymentTransactionObserver, AppStoreReceiptValidator {....
```

or 

```swift
extension SomeClass: SKPaymentTransactionObserver, AppStoreReceiptValidator {....
```

Than change your purchase code to look like this

```swift
case .Purchased:
    // Transaction is in queue, user has been charged.  Client should complete the transaction.
      
    let transactionID = transaction.payment.productIdentifier
    validateReceipt(forTransactionID: transactionID) { success in
          if success {
              // `StoreKit` event handlers may be called on a background queue. Ensure unlocking products gets called on main queue.
              dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                   /// Your code to unlock product for transactionID, I usually use delegation here
              }
          }
                    
         queue.finishTransaction(transaction) // Must be in completion closure
     }
  
case .Restored:
        // Transaction was restored from user's purchase history.  Client should complete the transaction.
          
        if let originalTransactionID = transaction.originalTransaction?.payment.productIdentifier {      
              validateReceipt(forTransactionID: originalTransactionID) { success in
                    if success {
                         // `StoreKit` event handlers may be called on a background queue. Ensure unlocking products gets called on main queue.
                         dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                              /// Your code to restore product for "originalTransactionID, I usually use delegation here
                         }
                    }
                    
                    queue.finishTransaction(transaction) // Must be in completion closure
              }
        }
                
```

# Final Note

As per apples guidlines you should alway first connect to apples production servers and than fall back on apples sandbox servers if needed. So bear this in mind when testing this in sandbox mode, validation will take a bit longer due to this.

The way this is actually done, all automatically with this helper, is that if connection to production servers fails you will get some error codes. There is an error code that tells you if your have a sandbox receipt but are using production url. The helper uses this error code to than do the receipt validation again with the sandbox server url.

If you use your own servers than instead of directly connecting to apples server enter your server url in the enum at the top of the .swift file and than adjust the validation methods accordingly to use that enum. I dont know how to than handle the above case where your should validate with product server first and than with sandbox on your server. I also dont know if any other changes to the helper are required.

I will try to update this in the future if I have a better grasp of what is needed for your own server.

# Release notes

- v1.0.1

Small change to the validation method. You now pass in the transaction identifier instead of the transaction itself. Pleas read the instructions again.

- v1.0

