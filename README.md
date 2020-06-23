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

### Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

To add a swift package to your project simple open your project in xCode and click File > Swift Packages > Add Package Dependency.
Than enter `https://github.com/crashoverride777/swifty-receipt-validator.git` as the repository URL and finish the setup wizard.

Alternatively if you have a Framwork that requires adding SwiftyReceiptValidator as a dependency is as easy as adding it to the dependencies value of your Package.swift.
```swift
dependencies: [
.package(url: "https://github.com/crashoverride777/swifty-receipt-validator.git", from: "6.1.0")
]
```

### Cocoa Pods

[CocoaPods](https://developers.google.com/admob/ios/quick-start#streamlined_using_cocoapods) is a dependency manager for Cocoa projects. 
Simply install the pod by adding the following line to your pod file
```swift
pod 'SwiftyReceiptValidator'
```

### Manually 

Altenatively you can drag the `Sources` folder and its containing files into your project.

## Usage

### Add import (if using cocoaPods or SwiftPackageManager)

- Add the import statement to your swift file(s) when you installed via cocoa pods or SwiftPackageManager

```swift
import SwiftyReceiptValidator
```

### Instantiate Receipt Validator

- Standard Configuration (Not Recommended)

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

- Custom Configuration (Recommended)

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
NOTE: Requires your own server
https://www.raywenderlich.com/23266/in-app-purchases-in-ios-6-tutorial-consumables-and-receipt-validation

### Validate Purchases

- Go to the following delegate method in your code, which you must implement for in app purchases

```swift
extension SomeClass: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
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
                // IMPORTANT: Finish the transaction ONLY after validation was successful
                // if validation error e.g due to internet, the transaction will stay in pending state
                // and than can/will be resumed on next app launch
                queue.finishTransaction(transaction)
            }
            print("Receipt validation was successfull with receipt response \(response)")
            // Unlock products and/or do additional checks
        case .failure(let error):
            print("Receipt validation failed with error \(error.localizedDescription)")  
            // Inform user of error
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
                // IMPORTANT: Finish the transaction ONLY after validation was successful
                // if validation error e.g due to internet, the transaction will stay in pending state
                // and than can/will be resumed on next app launch
                queue.finishTransaction(transaction)
            }
            print("Receipt validation was successfull with receipt response \(response)")
            // Unlock products and/or do additional checks
       case .failure(let error):
            print("Receipt validation failed with error \(error.localizedDescription)")  
            // Inform user of error
        }
    }              
```

Note: There is also Combine support for these methods if you are targeting iOS 13 and above

### Validate Subscriptions

- To validate your subscriptions (e.g on app launch), create a validationRequest object  `let validationRequest = SRVSubscriptionValidationRequest(...)` and  call `func validate(validationRequest)`. This will search for all subscription receipts.

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
        // Check the validSubscriptionReceipts and unlock products accordingly 
        // or disable features if no active subscriptions are found e.g.
        
        if response.validSubscriptionReceipts.isEmpty {
           // disable subscription features etc
        } else {
           // Validate subscription receipts are sorted by latest expiry date
           // enable subscription features etc
        }
        
    case .failure(let error):
        switch error {
        case .subscriptionExpired(let statusCode):
            // Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.
            // This receipt is valid but the subscription has expired. 
            
            // disable subscription features 
        default:
            break // do nothing e.g internet error or other errors
        }
    }
}
```

Setting `refreshLocalReceiptIfNeeded = true` will create a receipt fetch request if no receipt is found on the iOS device. This will show a iTunes password prompt so might not always be wanted e.g app launch.

If you want to check the users auto renewal status it is recommended, as far as I understand,  to 1st check the pending renewal info and than fall
back on the current subscription status. 

e.g 
```swift
let isAutoRenewOn: Bool
if let pendingRenewalInfo = response.receiptResponse.pendingRenewalInfo, !pendingRenewalInfo.isEmpty {
    isAutoRenewOn = pendingRenewalInfo.first { $0.autoRenewStatus == .on } != nil
} else {
    isAutoRenewOn = response.validSubscriptionReceipts.first { $0.autoRenewStatus == .on } != nil
}
```

Note: There is also Combine support for these methods if you are targeting iOS 13 and above

## Unit Tests

In order to unit tests your in app purchase class it is recommended to always inject the type protocol into your class instead of the concret implementation

- Not Recommended
```swift
class SomeClass {
    let receiptValidator: SwiftyReceiptValidator
    init(receiptValidator: SwiftyReceiptValidator) { ... }
}
```

- Recommended
```swift
class SomeClass {
    let receiptValidator: SwiftyReceiptValidatorType
    init(receiptValidator: SwiftyReceiptValidatorType) { ... }
}
```

- UnitTest example
```swift
class MockReceiptValidator { }
extension MockReceiptValidator: SwiftyReceiptValidatorType { ... }

class SomeClassTests {
    func test() {
        let sut = SomeClass(receiptValidator: MockReceiptValidator())
    }
}
```

- Mocking models
```swift
SRVReceiptResponse.mock()
SRVReceipt.mock()
SRVReceiptInApp.mock()
SRVPendingRenewalInfo.mock()
SRVSubscriptionValidationResponse.mock()
```
## StoreKit Alert Controllers

When you get to the purchase code and to the `.purchased` switch statement, StoreKit automatically shows an AlertController ("Thank you, purchase was succesfull"). This is the point receipt validation starts and you might want to display a custom loading/validation alert. I dont think you can disable showing the default alert.

## Final Note

As per apples guidlines you should always first connect to apples production servers and than fall back on apples sandbox servers if needed. So keep this in mind when testing in sandbox mode, validation will take a bit longer due to this.

I will try to update this in the future if I have a better grasp of what is needed for your own server.
