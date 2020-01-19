# Swifty Receipt Validator

[![Swift 5.0](https://img.shields.io/badge/swift-5.0-ED523F.svg?style=flat)](https://swift.org/download/)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyReceiptValidator.svg?style=flat)]()
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyReceiptValidator.svg)](https://img.shields.io/cocoapods/v/SwiftyReceiptValidator.svg)

A swift helper to handle app store receipt validation.

## Before you go live

- Test, Test, Test

Please test this properly, including production mode which will use apples production server URL. Use xcode release mode to test this to make sure everything is working. This is not something you want take lightly, triple check purchases are working when your app is in release mode.

## Requirements

- iOS 11.4+
- Swift 5.0+

## Installation

[CocoaPods](https://developers.google.com/admob/ios/quick-start#streamlined_using_cocoapods) is a dependency manager for Cocoa projects. 
Simply install the pod by adding the following line to your pod file

```swift
pod 'SwiftyReceiptValidator'
```

Altenatively you can drag the SwiftyReceiptValidator folder and its containing files manually into your project.

## Usage

- Add the import statement to your swift file(s) when you installed via cocoa pods

```swift
import SwiftyReceiptValidator
```

- In your class with your in app purchase code create a reference to SwiftyReceiptValidator

### Standard Configuration (Not Recommended)

```swift
class SomeClass {
    let receiptValidator: SwiftyReceiptValidatorType
    
    init() {
        // Standard configuration communicates with apples server directly, which is not recommended
        // Enable logging events in your console by setting isLoggingEnabled to true
        receiptValidator = SwiftyReceiptValidator(configuration: .standard, isLoggingEnabled: false)
    }
}
```

### Custom Configuration (Recommended)

// Note: Requires your own server

```swift
class SomeClass {
    let receiptValidator: SwiftyReceiptValidatorType
    
    init() {
        // The recommended approach is to communicate with your own webserver
        // which would than connect with apples server
        let configuration = SRVConfiguration(
            productionURL: "someProductionURL",
            sandboxURL: "someSandboxURL",
            sessionConfiguration: .default
        )
        
        // Enable logging events in your console by setting isLoggingEnabled to true
        receiptValidator = SwiftyReceiptValidator(configuration: configuration, isLoggingEnabled: false)
    }
}
```

https://www.raywenderlich.com/23266/in-app-purchases-in-ios-6-tutorial-consumables-and-receipt-validation

### Validate purchases

- Go to the following delegate method in your code, which you must implement for in app purchases

```swift
extension SomeClass: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            switch $0.transactionState {
                case .purchased:
                ...
                case .restored:
                ...
            }
        }
    }
}
```

and modify the `.purchased` and `.restored` enum cases to look like this


```swift
case .purchased:
    // Transaction is in queue, user has been charged.  Client should complete the transaction.
    let productId = transaction.payment.productIdentifier

    let validationRequest = SRVPurchaseValidationRequest(
        productId: productId,
        sharedSecret: "your secret or nil" // Enter your shared secret if your have set one on iTunes, otherwise set to nil
    )
        
    receiptValidator.validate(validationRequest) { result in
        switch result {
        case .success(let response):
            defer {
                // IMPORTANT: Complete the transaction ONLY after validation was successful
                // if validation error e.g due to internet, the transaction will stay in pending state
                // and than can/will be resumed on next app launch
                queue.finishTransaction(transaction)
            }
            print("Receipt validation was successfull with receipt response \(response)")
            // Unlock products and/or do additional checks
        case .failure(let error, let code):
            print("Receipt validation failed with code \(code), error \(error.localizedDescription)")    
            // Inform user of error, maybe try validation again.
        }
    }
            
case .restored:
    // Transaction was restored from user's purchase history.  Client should complete the transaction.
    guard let productId = transaction.originalTransaction?.payment.productIdentifier else {
        queue.finishTransaction(transaction)
        return
    }
    
    let validationRequest = SRVPurchaseValidationRequest(
        productId: productId,
        sharedSecret: "your secret or nil" // Enter your shared secret if your have set one on iTunes, otherwise set to nil
    )
    
    receiptValidator.validate(validationRequest) { result in
        switch result {
        case .success(let response):
            defer {
                // IMPORTANT: Complete the transaction ONLY after validation was successful
                // if validation error e.g due to internet, the transaction will stay in pending state
                // and than can/will be resumed on next app launch
                queue.finishTransaction(transaction)
            }
            print("Receipt validation was successfull with receipt response \(response)")
            // Unlock products and/or do additional checks
       case .failure(let error, let code):
            print("Receipt validation failed with code \(code), error \(error.localizedDescription)")  
            // Inform user of error, maybe try validation again.
        }
    }              
```

Note: There is also Combine support for these methods if you are targeting iOS 13 and above

### Validate subscriptions

- To validate your subscriptions (e.g on app launch), create a validationRequest object  `let validationRequest = SRVSubscriptionValidationRequest(...)` and  `func validate(validationRequest)`. This will search for all subscription receipts and check if there is at least 1 thats not expired.

```swift
let validationRequest = SRVSubscriptionValidationRequest(
    sharedSecret: "your shared secret",
    refreshLocalReceiptIfNeeded: false,
    excludeOldTransactions: false,
    now: Date()
)
receiptValidator.validate(validationRequest) { result in
    switch result {
    case .success(let response):
        print("Receipt validation was successfull with receipt response \(response)")
        print(response.validSubscriptionReceipts) // convenience array for active receipts
        print(response.receiptResponse) // full receipt response
        print(response.receiptResponse.pendingRenewalInfo)
        // Unlock subscription features and/or do additional checks first
    case .failure(let error, let code):
        switch error {
        print(error.statusCode)
        case .noValidSubscription:
            // no active subscription found, update your cache/app etc
        default:
            break // do nothing e.g internet error or other errors
        }
    }
}
```

Setting refreshLocalReceiptIfNeeded = true will create a receipt fetch request if no receipt is found on the iOS device. This will show a iTunes password prompt so might always be wanted e.g app launch.

Note: There is also Combine support for these methods if you are targeting iOS 13 and above

## Unit Tests

In order to unit tests your in app purchase class it is recommended to always inject the type protocol into your class instead of the concret implementation

Not Recommended
```swift
class SomeClass {
    let receiptValidator: SwiftyReceiptValidator
    init(receiptValidator: SwiftyReceiptValidator) { ... }
}
```

Recommended
```swift
class SomeClass {
    let receiptValidator: SwiftyReceiptValidatorType
    init(receiptValidator: SwiftyReceiptValidatorType) { ... }
}
```

This way it is very easy to mock SwiftyReceiptValidator in your in app purchase class e.g

```swift
class SomeClassTests {
    func test() {
        let sut = SomeClass(receiptValidator: MockReceiptValidator())
    }
}
```

All models that require mocking have a dedicated mock object that should be used

```swift
SRVReceiptResponse.mock()
SRVReceipt.mock()
SRVReceiptInApp.mock()
SRVPendingRenewalInfo.mock()
SRVSubscriptionValidationResponse.mock()
```
## StoreKit Alert Controllers

One thing I do not know about receipt validation is if there is a way to stop the default StoreKit alert controller to show. When you get to the purchase code and to the `.purchased` switch statement, storeKit automatically shows an AlertController ("Thank you, purchase was succesfull"). This however is the point where receipt validation is actually starting so it takes another few seconds for the products to unlock. I guess this must be normal, although it would be nicer to show that alert once receipt validation is finished.

## Final Note

As per apples guidlines you should always first connect to apples production servers and than fall back on apples sandbox servers if needed. So keep this in mind when testing in sandbox mode, validation will take a bit longer due to this.

I will try to update this in the future if I have a better grasp of what is needed for your own server.
