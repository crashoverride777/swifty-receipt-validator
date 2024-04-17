[![Swift 5.8](https://img.shields.io/badge/swift-5.8-ED523F.svg?style=flat)](https://swift.org/download/)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyReceiptValidator.svg?style=flat)]()
[![SPM supported](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyReceiptValidator.svg)](https://img.shields.io/cocoapods/v/SwiftyReceiptValidator.svg)

# SwiftyReceiptValidator

A Swift library to handle App Store receipt validation.

- [iOS 15](#iOS_15)
- [Before you go live](#before-you-go-live)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [StoreKit Alert Controllers](#storeKit-alert-controllers)
- [Final Note](#final-note)
- [License](#license)

## iOS 15

Apple has released a new in app purchase API with iOS 15 which includes receipt validation. 
If your app supports iOS 15 or higher I would highly recommend to implement this new API.

https://developer.apple.com/documentation/storekit/choosing_a_storekit_api_for_in-app_purchase

## Before you go live

- Test, Test, Test

Please test this properly, including production mode which will use apples production server URL. Use Xcode`s release mode to test this to make sure everything is working. This is not something you want take lightly, triple check purchases are working when your app is in release mode.

## Requirements

- iOS 13.0+
- Swift 5.8+

## Installation

### Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

To add a swift package to your project simple open your project in xCode and click File > Swift Packages > Add Package Dependency.
Than enter `https://github.com/crashoverride777/swifty-receipt-validator.git` as the repository URL and finish the installation wizard.

Alternatively if you have another swift package that requires `SwiftyReceiptValidator` as a dependency it is as easy as adding it to the dependencies value of your Package.swift.
```swift
dependencies: [
.package(url: "https://github.com/crashoverride777/swifty-receipt-validator.git", from: "7.0.0")
]
```

### Cocoa Pods

[CocoaPods](https://developers.google.com/admob/ios/quick-start#streamlined_using_cocoapods) is a dependency manager for Cocoa projects. 
Simply install the pod by adding the following line to your pod file
```swift
pod 'SwiftyReceiptValidator'
```

### Manually

Alternatively you can drag the `Sources` folder and its containing files into your project.

## Usage

### Add import

- Add the import statement to your swift file(s) when you installed via SwiftPackageManager or CocoaPods

```swift
import SwiftyReceiptValidator
```

### Instantiate Receipt Validator

Instantiate `SwiftyReceiptValidator` inside your class that handles in app purchases.

- Custom Configuration (Recommended)

Apple's official recommendation to perform receipt validation is to connect to your own server, which then connects to Apple's servers to validate the receipts.

```swift
class SomeClass {
    let receiptValidator: SwiftyReceiptValidatorType
    
    init() {
        let configuration = SRVConfiguration(
            productionURL: "your validation server production url",
            sandboxURL: "your validation server sandbox url",
            sessionConfiguration: .default
        )
        
        receiptValidator = SwiftyReceiptValidator(configuration: configuration, isLoggingEnabled: false)
    }
}
```

Your own webserver would than send the received response to apples servers for validation

- `https://buy.itunes.apple.com/verifyReceipt`
- `https://sandbox.itunes.apple.com/verifyReceipt`

and handle the response and then send it back to the iOS app for final validation.

- Standard Configuration (Not Recommended)

Standard configuration works without your own webserver by sending the validation request directly to apples servers. This approach is not very secure and is therefore not recommended.

```swift
class SomeClass {
    let receiptValidator: SwiftyReceiptValidatorType
    
    init() {
        receiptValidator = SwiftyReceiptValidator(configuration: .standard, isLoggingEnabled: false)
    }
}
```

### Validate Purchases

- Go to the following delegate method in your in app purchase code, which you must implement for in app purchases (old API).

```swift
extension SomeClass: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
                ...
            }
        }
    }
}
```

and modify the `.purchased` case to look like this


```swift
case .purchased:
    // Transaction is in queue, user has been charged.  Client should complete the transaction.
    let productIdentifier = transaction.payment.productIdentifier

    let validationRequest = SRVPurchaseValidationRequest(
        productIdentifier: productIdentifier,
        sharedSecret: "your shared secret setup in iTunesConnect or nil when dealing with non-subscription purchases"
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

Note: `Combine` support is also available.

```swift
let cancellable = receiptValidator
    .validatePublisher(for: validationRequest)
    .map { response in
        print(response)
    }
    .mapError { error in
        print(error)
    }
```

Note: `Async` support is also available.

```swift
do {
    let response = try await receiptValidator.validate(validationRequest)
    print(response)
} catch {
    print(error)
}
```

### Validate Subscriptions

- To validate your subscriptions (e.g. on app launch), create a subscription validation request and validate it. This will search for all subscription receipts found on the device.

```swift
let validationRequest = SRVSubscriptionValidationRequest(
    sharedSecret: "your shared secret setup in iTunesConnect",
    refreshLocalReceiptIfNeeded: false,
    excludeOldTransactions: false,
    now: Date()
)
receiptValidator.validate(validationRequest) { result in
    switch result {
    
    case .success(let response):
        print(response.receiptResponse) // full receipt response
        print(response.validSubscriptionReceipts) // convenience array for active subscription receipts

        // Check the validSubscriptionReceipts and unlock products accordingly 
        // or disable features if no active subscriptions are found e.g.
        
        if response.validSubscriptionReceipts.isEmpty {
           // disable subscription features etc
        } else {
           // Valid subscription receipts are sorted by latest expiry date
           // enable subscription features etc
        }
        
    case .failure(let error):
        switch error as? SRVError {
        case .noReceiptFoundInBundle:
             break
             // do nothing, see description below
        case .subscriptioniOS6StyleExpired(let statusCode):
            // Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.
            // This receipt is valid but the subscription has expired. 
            
            // disable subscription features 
        default:
            // do nothing or inform user of error during validation e.g UIAlertController
        }
    }
}
```

Setting `refreshLocalReceiptIfNeeded` to `true` will create a `SKReceiptRefreshRequest` if no receipt is found in your apps bundle.

I would recommend to always set this flag to `false` for the following reasons.
1. Creating a `SKReceiptRefreshRequest` will always show an iTunes password prompt which might not be wanted in your apps flow.
2. When you call this at app launch you can handle the returned `SRVError.noReceiptFoundInBundle` error discretly.
3. Once a user made an in app purchase there should always be a receipt in your apps bundle.
4. Users re-installing your app which have an existing subscription should use the restore functionality in your app which is a requirement when using in app purchases. This will add the receipt(s) in your apps bundle and then subscriptions can be validated afterwards. (https://developer.apple.com/documentation/storekit/skpaymentqueue/1506123-restorecompletedtransactions).

Note: `Combine` support is also available.

```swift
let cancellable = receiptValidator
    .validatePublisher(for: validationRequest)
    .map { response in
        print(response)
    }
    .mapError { error in
        print(error)
    }
```

Note: `Async` support is also available.

```swift
do {
    let response = try await receiptValidator.validate(validationRequest)
    print(response)
} catch {
    print(error)
}
```

### Check auto-renew status

If you want to check the users auto renewal status it is recommended, as far as I understand,  to 1st check the pending renewal info and than fall
back on the current subscription status. 

```swift
let validationRequest = SRVSubscriptionValidationRequest(...)
receiptValidator.validate(validationRequest) { result in
    switch result {
    case .success(let response):
    
        let isAutoRenewOn: Bool
        if let pendingRenewalInfo = response.receiptResponse.pendingRenewalInfo, !pendingRenewalInfo.isEmpty {
            isAutoRenewOn = pendingRenewalInfo.contains(where: { $0.autoRenewStatus == .on })
        } else {
            isAutoRenewOn = response.validSubscriptionReceipts.contains(where: { $0.autoRenewStatus == .on })
        }
    
    case .failure(let error):
        ...
    }
}
```

### Show Introductory Price

If a previous subscription period in the receipt has the value “true” for either the` is_trial_period` or the `is_in_intro_offer_period` key,
the user is not eligible for a free trial or introductory price within that subscription group.
`SwiftyReceiptValidator` provides a convenience boolean for this

```swift
let validationRequest = SRVSubscriptionValidationRequest(...)
receiptValidator.validate(validationRequest) { result in
    switch result {
    case .success(let response):
        response.validSubscriptionReceipts.forEach { receipt in
            print(receipt.canShowIntroductoryPrice)
        }
    case .failure(let error):
    ...
}
```

## Testing

In order to test your in app purchase class it is recommended to always inject the type protocol into your class instead of the concret implementation

- Not Recommended
```swift
class SomeClass {
    private let receiptValidator: SwiftyReceiptValidator
    init(receiptValidator: SwiftyReceiptValidator) { ... }
}
```

- Recommended
```swift
class SomeClass {
    private let receiptValidator: SwiftyReceiptValidatorType
    init(receiptValidator: SwiftyReceiptValidatorType) { ... }
}
```

- UnitTest example
```swift
class StubReceiptValidator { }
extension StubReceiptValidator: SwiftyReceiptValidatorType { 
    // implement SwiftyReceiptValidatorType protocol methods and return stub data (see Mocking Models below)
 }

class SomeClassTests {
    func testSomething() {
        let sut = SomeClass(receiptValidator: StubReceiptValidator())
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

When you get to the purchase code and to the `.purchased` switch statement, StoreKit automatically shows an AlertController ("Thank you, purchase was succesfull"). This is the point receipt validation starts and you might want to display a custom loading/validation alert. I dont think you can disable showing this default alert.

## Final Note

As per Apples guidlines you should always first connect to apples production servers and than fall back on Apples sandbox servers 
if needed. So keep this in mind when testing in sandbox mode, validation may take a bit longer.

## License

SwiftyReceiptValidator is released under the MIT license. [See LICENSE](https://github.com/crashoverride777/swifty-receipt-validator/blob/master/LICENSE) for details.
