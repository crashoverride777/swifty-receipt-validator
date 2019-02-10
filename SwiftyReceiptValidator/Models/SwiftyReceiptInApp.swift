//
//  SwiftyReceiptInApp.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public struct SwiftyReceiptInApp: Codable {
    // The number of items purchased. This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
    public let quantity: String
     // The product identifier of the item that was purchased. This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
    public let productId: String
    // The transaction identifier of the item that was purchased. This value corresponds to the transaction’s transactionIdentifier property.
    public let transactionId: String
    // For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier. This value corresponds to the original transaction’s transactionIdentifier property. All receipts in a chain of renewals for an auto-renewable subscription have the same value for this field.
    public let originalTransactionId: String
    // The date and time that the item was purchased. This value corresponds to the transaction’s transactionDate property.
    public let purchaseDate: Date
    // For a transaction that restores a previous transaction, the date of the original transaction. This value corresponds to the original transaction’s transactionDate property. In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renewed.
    public let originalPurchaseDate: Date
   
    // The expiration date for the subscription, expressed as the number of milliseconds since January 1, 1970, 00:00:00 GMT. This key is only present for auto-renewable subscription receipts.
    public let expiresDate: Date?
    // For an expired subscription, the reason for the subscription expiration. This key is only present for a receipt containing an expired auto-renewable subscription. You can use this value to decide whether to display appropriate messaging in your app for customers to resubscribe.
    public let expirationIntent: ExpirationIntent?
    // For an expired subscription, whether or not Apple is still attempting to automatically renew the subscription.
    public let isInBillingRetryPeriod: ExpirationRetry?
    // For a subscription, whether or not it is in the free trial period.
    public let isTrialPeriod: String?
    // For an auto-renewable subscription, whether or not it is in the introductory price period.
    public let isInIntroOfferPeriod: String?
    // The current renewal status for the auto-renewable subscription.
    public let autoRenewStatus: SubscriptionRenewStatus?
    
    // For a transaction that was canceled by Apple customer support, the time and date of the cancellation. For an auto-renewable subscription plan that was upgraded, the time and date of the upgrade transaction
    public let cancellationDate: Date?
    // For a transaction that was canceled, the reason for cancellation.
    public let cancellationReason: CancellationReason?
    
    // Other
    public let appItemId: String
    public let versionExternalIdentifier: String
    public let webOrderLineItemId: String
}

// MARK: - Types

public extension SwiftyReceiptInApp {
    
    enum ExpirationIntent: String, Codable {
        // Customer canceled their subscription
        case cancelled = "1"
        // Billing error; for example customer’s payment information was no longer valid
        case billingError = "2"
        // Customer did not agree to a recent price increase
        case notAggreedToPriceIncrease = "3"
        // Product was not available for purchase at the time of renewal
        case productNotAvailable = "4"
        // Unknown error
        case unknown = "5"
    }
    
    enum ExpirationRetry: String, Codable {
        // App Store has stopped attempting to renew the subscription
        case stoppedTryingToRenew = "0"
        // App Store is still attempting to renew the subscription
        case stillTryingToRenew = "1"
    }
    
    enum CancellationReason: String, Codable {
        // Transaction was canceled for another reason, for example, if the customer made the purchase accidentally.
        case cancelledForOtherReason = "0"
        // Customer canceled their transaction due to an actual or perceived issue within your app
        case customerCancelledDueToErrorInApp = "1"
    }
    
    enum SubscriptionRenewStatus: String, Codable {
        // Customer has turned off automatic renewal for their subscription
        case off = "0"
        // Subscription will renew at the end of the current subscription period
        case on = "1"
    }
}
