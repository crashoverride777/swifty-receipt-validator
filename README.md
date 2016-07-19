# Swift App Store Receipt Validator

A swift protocol extension to handle app store receipt validation.

NOTE: 

The recommned way by apple is to use your own server and than communicate to apples server to validate receipt.
However for obvious reason this is a hassle for alot of people, e.g me, because I dont have a webserver and dont understand languages like PHP to make it work.

So if you dont want to use your own server that you can communcate directly with apples servers. Apple even has made their own in app receipt validator to show this (tutorials on ray wenderlich, in objC tho). Doing this is apparently not very secure and therefore you should use your own server before sending stuff to apple. 

Nevertheless its still better than not doing any validation at all and simply unlocking the product directly.


# Set-Up

- Add the AppStoreReceipValidator.swift and AppStoreReceiptObtainer.swift file to your project.

# How to use

In your in app purchase code go the method

```swift
func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) { ....
```

where you should have these to enums to handle app purchases and restores. The code there should look more or less like this

```swift
for transaction in transactions {
      switch transaction.transactionState {


     case .Purchased:
          // Transaction is in queue, user has been charged.  Client should complete the transaction.
                
          /// Your code to unlock product for payment id
          queue.finishTransaction(transaction)
              
     case .Restored:
          // Transaction was restored from user's purchase history.  Client should complete the transaction.
                
          if let originalTransaction = transaction.originalTransaction {
               /// Your code to unlock product for transaction ID
         }
         queue.finishTransaction(transaction)
         
    case .Failed:
         ....
} 
```


To use the receipt validator go the the class that has your in app purchase code. Go to where you added the sk payment transaction observer and
confirm to the AppStoreReceiptValidator protocol 

class SomeClass: ... , SKPaymentTransactionObserver, AppStoreReceiptValidator {....

and than change your purchase code to look like this

```swift
case .Purchased:
    // Transaction is in queue, user has been charged.  Client should complete the transaction.
                
    validateReceipt(forTransaction: transaction) { success in
          if success {
              // `StoreKit` event handlers may be called on a background queue. Ensure unlocking products gets called on main queue.
              dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                   /// Your code to unlock product for "transaction.payment.productIdentifier"
                  /// I usually use delegation here, passing in the prodcutID, to unlock the correct product.
              }
          }
                    
         queue.finishTransaction(transaction) // Must be in completion closure
}
  
case .Restored:
        // Transaction was restored from user's purchase history.  Client should complete the transaction.
                
        validateReceipt(forTransaction: transaction) { success in
             if success {
                   // `StoreKit` event handlers may be called on a background queue. Ensure unlocking products gets called on main queue.
                  dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                       if let originalTransaction = transaction.originalTransaction {
                             /// Your code to restore product for "originalTransaction.payment.productIdentifier"
                             /// I usually use delegation here, passing in the originalTransactionId, to unlock the correct product.
                       }
                  }
             }
                    
             queue.finishTransaction(transaction) // Must be in completion closure
}
                
```

Note:

As per apples guidlines you should alway first connect to apples production servers and than fall back on apples sandbox servers.
The way this is done, (all automatically with this helper) is that if connection to production servers fails you will receip some error codes. There is a error code that tells you if your have a sandbox receipt but are using production. The helper uses this error code to than do the receipt validation again with the sandbox servers.

If you use your own servers than instead of directly connecting to apples server enter your server url in the enum at the top of the .swift file and than adjust the validation methods accordingly. I dont know how to than handle the above case where your should validate with product server first and than with sandbox if correct error, on your server. I also dont know if any other changes are required.

I will try to update this in the future if I have a better grasp if what is needed for your own server.


# Final Info

I welcome as as much feedback as possible, so please dont hestitate to open a issue or email me. This way we can make sure this helper is as solid as it can be.

# Release notes

- v 1.0

