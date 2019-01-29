//
//  SwiftyReceiptResponse.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public struct SwiftyReceiptResponse: Codable {
    // A JSON representation of the receipt that was sent for verification. For information about keys found in a receipt, see Receipt Fields.
    let receipt: SwiftyReceipt
    // See ReceiptStatusCode. For iOS 6 style transaction receipts, the status code reflects the status of the specific transaction’s receipt. For iOS 7 style app receipts, the status code is reflects the status of the app receipt as a whole. For example, if you send a valid app receipt that contains an expired subscription, the response is 0 because the receipt as a whole is valid.
    let status: Int
    // The current environment, Sandbox or Production
    let environment: String
    // Only returned for iOS 6+ style transaction receipts for auto-renewable subscriptions. The base-64 encoded transaction receipt for the most recent renewal.
    let latestReceipt: SwiftyReceipt? // iOS 6 only
    // Only returned for iOS 6+ style transaction receipts for auto-renewable subscriptions. The JSON representation of the receipt for the most recent renewal.
    let latestReceiptInfo: String? // iOS 6 only
}
