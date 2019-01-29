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
    public let purchaseDateMs: String
    public let purchaseDatePst: Date
    // For a transaction that restores a previous transaction, the date of the original transaction. This value corresponds to the original transaction’s transactionDate property. In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renewed.
    public let originalPurchaseDate: Date
    public let originalPurchaseDateMs: String
    public let originalPurchaseDatePst: Date
    // The expiration date for the subscription, expressed as the number of milliseconds since January 1, 1970, 00:00:00 GMT. This key is only present for auto-renewable subscription receipts.
    public let expiresDate: Date?
    // Check if we are in trial period.
    public let isTrialPeriod: Bool
}
