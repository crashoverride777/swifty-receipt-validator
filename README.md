# Swift Music Helper

A swift protocol extension to handle app store receipt validation.

# Set-Up

- Add the AppStoreReceipValidator.swift and AppStoreReceiptObtainer.swift file to your project.

# How to use

In your in app purchase code go the method

```swift
func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) { ....
```

where you should have these to enums to handle app purchases and restores which shoud more or less look like this

```swift
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
                        }
                    }
                    
                    queue.finishTransaction(transaction) // Must be in completion closure
                }
                */
case .Restored:
                // Transaction was restored from user's purchase history.  Client should complete the transaction.
                
                validateReceipt(forTransaction: transaction) { success in
                    if success {
                        // `StoreKit` event handlers may be called on a background queue. Ensure unlocking products gets called on main queue.
                        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                            if let originalTransaction = transaction.originalTransaction {
                                Your code to restore product for "originalTransaction.payment.productIdentifier"
                            }
                        }
                    }
                    
                    queue.finishTransaction(transaction) // Must be in completion closure
                }
                
```


NOTE: By default the helper supports mp3 and wav as file formats. If you have another format go to the helper and update the prepare method with the new file extension.


# Release notes

- v 1.0

