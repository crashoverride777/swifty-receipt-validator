import Foundation

public struct SRVReceiptInApp: Codable, Equatable {
    // The number of items purchased.
    // This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
    public let quantity: String
    // The product identifier of the item that was purchased.
    // This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s
    // payment property.
    public let productId: String
    // The transaction identifier of the item that was purchased.
    // This value corresponds to the transaction’s transactionIdentifier property.
    // For a transaction that restores a previous transaction, this value is different from
    // the transaction identifier of the original purchase transaction.
    // In an auto-renewable subscription receipt, a new value for the transaction identifier
    // is generated every time the subscription automatically renews or is restored on a new device.
    public let transactionId: String
    // For a transaction that restores a previous transaction, the transaction identifier of the original transaction.
    // Otherwise, identical to the transaction identifier.
    // This value corresponds to the original transaction’s transactionIdentifier property.
    // All receipts in a chain of renewals for an auto-renewable subscription have the same value for this field.
    // This value is the same for all receipts that have been generated for a specific subscription.
    // This value is useful for relating together multiple iOS 6 style transaction receipts for the same
    // individual customer’s subscription.
    public let originalTransactionId: String
    // The date and time that the item was purchased.
    // This value corresponds to the transaction’s transactionDate property.
    // For a transaction that restores a previous transaction,
    // the purchase date is the same as the original purchase date.
    // Use Original Purchase Date to get the date of the original transaction.
    // In an auto-renewable subscription receipt, the purchase date is the date when the subscription was either
    // purchased or renewed (with or without a lapse). For an automatic renewal that occurs on the expiration date
    // of the current period, the purchase date is the start date of the next period,
    // which is identical to the end date of the current period.
    public let purchaseDate: Date
    // For a transaction that restores a previous transaction, the date of the original transaction.
    // This value corresponds to the original transaction’s transactionDate property.
    // In an auto-renewable subscription receipt, this indicates the beginning of the subscription period,
    // even if the subscription has been renewed.
    public let originalPurchaseDate: Date
    // The expiration date for the subscription, expressed as the number of milliseconds since January 1, 1970, 00:00:00 GMT.
    // This key is only present for auto-renewable subscription receipts.
    // Use this value to identify the date when the subscription will renew or expire,
    // to determine if a customer should have access to content or service.
    // After validating the latest receipt, if the subscription expiration date for the latest renewal
    // transaction is a past date, it is safe to assume that the subscription has expired.
    public let expiresDate: Date?
    // For an expired subscription, the reason for the subscription expiration.
    // This key is only present for a receipt containing an expired auto-renewable subscription.
    // You can use this value to decide whether to display appropriate messaging in your app for customers to resubscribe.
    public let expirationIntent: ExpirationIntent?
    // For an expired subscription, whether or not Apple is still attempting to automatically renew the subscription.
    // This key is only present for auto-renewable subscription receipts.
    // If the customer’s subscription failed to renew because the App Store was unable to complete the transaction,
    // this value will reflect whether or not the App Store is still trying to renew the subscription.
    public let isInBillingRetryPeriod: ExpirationRetry?
    // For a subscription, whether or not it is in the free trial period.
    // This key is only present for auto-renewable subscription receipts.
    // The value for this key is "true" if the customer’s subscription is currently in the free trial period, or "false" if not.
    // Note: If a previous subscription period in the receipt has the value “true” for either the is_trial_period or the is_in_intro_offer_period key, the user is not eligible for a free trial or introductory price within that subscription group.
    public let isTrialPeriod: String?
    // For an auto-renewable subscription, whether or not it is in the introductory price period.
    // This key is only present for auto-renewable subscription receipts.
    // The value for this key is "true" if the customer’s subscription is currently in an introductory price period, or "false" if not.
    public let isInIntroOfferPeriod: String?
    // For a transaction that was canceled by Apple customer support, the time and date of the cancellation.
    // For an auto-renewable subscription plan that was upgraded, the time and date of the upgrade transaction
    // Treat a canceled receipt the same as if no purchase had ever been made.
    public let cancellationDate: Date?
    // For a transaction that was canceled, the reason for cancellation.
    public let cancellationReason: CancellationReason?
    // A string that the App Store uses to uniquely identify the application that created the transaction.
    // Use this value along with the cancellation date to identify possible issues in your app that may lead
    // customers to contact Apple customer support.
    public let appItemId: String?
    // An arbitrary number that uniquely identifies a revision of your application.
    public let versionExternalIdentifier: String?
    // The primary key for identifying subscription purchases.
    // This key is not present for receipts created in the test environment.
    // Use this value to identify the version of the app that the customer bought.
    public let webOrderLineItemId: String?
    // The current renewal status for the auto-renewable subscription.
    // This key is only present for auto-renewable subscription receipts, for active or expired subscriptions.
    // The value for this key should not be interpreted as the customer’s subscription status.
    // You can use this value to display an alternative subscription product in your app, for example,
    // a lower level subscription plan that the customer can downgrade to from their current plan.
    public let autoRenewStatus: SRVAutoRenewStatus?
    // The current renewal preference for the auto-renewable subscription.
    // This key is only present for auto-renewable subscription receipts.
    // The value for this key corresponds to the productIdentifier property of the product
    // that the customer’s subscription renews. You can use this value to present
    // an alternative service level to the customer before the current subscription period ends.
    public let autoRenewProductId: String?
    // The current price consent status for a subscription price increase.
    // This key is only present for auto-renewable subscription receipts if the subscription
    // price was increased without keeping the existing price for active subscribers.
    // You can use this value to track customer adoption of the new price and take appropriate action.
    public let priceConsentStatus: PriceConsentStatus?
}

// MARK: - Types

public extension SRVReceiptInApp {
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

    enum PriceConsentStatus: String, Codable {
        // Customer has not taken action regarding the increased price.
        // Subscription expires if the customer takes no action before the renewal date.
        case notTakenActionForIncreasedPrice = "0"
        // Customer has agreed to the price increase. Subscription will renew at the higher price.
        case aggreedToPriceIncrease = "1"
    }
}

// MARK: - Computed

public extension SRVReceiptInApp {
    /*
    If a previous subscription period in the receipt has the value “true”
    for either the is_trial_period or the is_in_intro_offer_period key,
    the user is not eligible for a free trial or introductory price within that subscription group.
    */
    var canShowIntroductoryPrice: Bool {
        if isTrialPeriod == "true" || isInIntroOfferPeriod == "true" {
            return false
        }
        return true
    }
}
