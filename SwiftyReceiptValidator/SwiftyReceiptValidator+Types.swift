//
//  SwiftyReceiptValidator+Types.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

//    The MIT License (MIT)
//
//    Copyright (c) 2016-2018 Dominik Ringler
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation

/// SwiftyReceiptValidator types
public extension SwiftyReceiptValidator {
    
    // MARK: - URLs
    
    enum URLString: String {
        case sandbox    = "https://sandbox.itunes.apple.com/verifyReceipt"
        case production = "https://buy.itunes.apple.com/verifyReceipt"
    }
    
    // MARK: - HTTP Method
    
    enum HTTPMethod: String {
        case post = "POST"
    }
    
    // MARK: - JSON Keys
    
    enum JSONObjectKey: String {
        case receiptData = "receipt-data"
        case password
    }
    
    // MARK: - Result
    
    /// The result enum of a validation request. Returns a success or failure case with a corresponding value
    public enum Result<T> {
        case success(data: T)
        case failure(code: Int?, error: ErrorType)
    }
    
    // MARK: - Errors
    
    /// Validation errors
    public enum ErrorType: Error {
        case unknown
        case url
        case data
        case json
        case noStatusCodeFound
        case invalidStatusCode
        case noReceiptFound
        case noReceiptInJSON
        case bundleIdNotMatching
        case productIdNotMatching
        case other(Error)
        
        public var localizedDescription: String {
            let message: String
            
            switch self {
            case .unknown:
                message = "Unknown error"
            case .url:
                message = "URL error"
            case .data:
                message = "Data error"
            case .json:
                message = "JSON error"
            case .noStatusCodeFound:
                message = "No status code found"
            case .invalidStatusCode:
                message = "Invalid status code"
            case .noReceiptFound:
                message = "No receipt found on device"
            case .noReceiptInJSON:
                message = "No receipt found in json response"
            case .bundleIdNotMatching:
                message = "Bundle id is not matching receipt"
            case .productIdNotMatching:
                message = "Product id is not matching with receipt"
            case .other(let error):
                message = error.localizedDescription
            }
            return "SwiftyReceiptValidator " + message
        }
    }
    
    // MARK: - Status Code
    
    /// Status codes
    public enum StatusCode: Int {
        case unknown = -2
        case none = -1
        case valid = 0
        case jsonNotReadable = 21000
        case malformedOrMissingData = 21002
        case receiptCouldNotBeAuthenticated = 21003
        case sharedSecretNotMatching = 21004
        case receiptServerUnavailable = 21005
        case subscriptionExpired = 21006
        case testReceipt = 21007
        case productionEnvironment = 21008
        
        public var description: String {
            switch self {
            case .unknown:
                return "No decodable status"
            case .none:
                return "No status returned"
            case .valid:
                return "Valid status"
            case .jsonNotReadable:
                return "The App Store could not read the JSON object you provided."
            case .malformedOrMissingData:
                return "The data in the receipt-data property was malformed or missing."
            case .receiptCouldNotBeAuthenticated:
                return "The receipt could not be authenticated."
            case .sharedSecretNotMatching:
                return "The shared secret you provided does not match the shared secret on file for your account. Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions."
            case .receiptServerUnavailable:
                return "The receipt server is currently not available."
            case .subscriptionExpired:
                return "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions."
            case .testReceipt:
                return "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead."
            case .productionEnvironment:
                return "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead."
            }
        }
    }
    
    // MARK: - Response Key
    
    /// Response keys
    public enum ResponseKey: String {
        // See ReceiptStatusCode. For iOS 6 style transaction receipts, the status code reflects the status of the specific transaction’s receipt. For iOS 7 style app receipts, the status code is reflects the status of the app receipt as a whole. For example, if you send a valid app receipt that contains an expired subscription, the response is 0 because the receipt as a whole is valid.
        case status
        // A JSON representation of the receipt that was sent for verification. For information about keys found in a receipt, see Receipt Fields.
        case receipt
        // Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions. The base-64 encoded transaction receipt for the most recent renewal.
        case latestReceipt = "latest_receipt"
        // Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions. The JSON representation of the receipt for the most recent renewal.
        case latestReceiptInfo = "latest_receipt_info"
        
        public var description: String {
            switch self {
            case .status:
                return "See ReceiptStatusCode. For iOS 6 style transaction receipts, the status code reflects the status of the specific transaction’s receipt. For iOS 7 style app receipts, the status code is reflects the status of the app receipt as a whole. For example, if you send a valid app receipt that contains an expired subscription, the response is 0 because the receipt as a whole is valid."
            case .receipt:
                return "A JSON representation of the receipt that was sent for verification. For information about keys found in a receipt, see Receipt Fields."
            case .latestReceipt:
                return "Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions. The base-64 encoded transaction receipt for the most recent renewal."
            case .latestReceiptInfo:
                return "Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions. The JSON representation of the receipt for the most recent renewal."
            }
        }
    }
    
    // MARK: - Info Key
    
    /// Info keys
    public enum InfoKey: String {
         // This corresponds to the value of CFBundleIdentifier in the Info.plist file.
        case bundleId = "bundle_id"
        // This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist.
        case applicationVersion = "application_version"
        // The version of the app that was originally purchased. This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist file when the purchase was originally made.
        case originalApplicationVersion = "original_application_version"
        // The date when the app receipt was created.
        case creationDate = "creation_date"
        // The date that the app receipt expires. This key is present only for apps purchased through the Volume Purchase Program.
        case expirationDate = "expiration_date"
        // The receipt for an in-app purchase. This will be an array of dictionaries with all your individial receipts. See below
        case inApp = "in_app"
        
        public enum InApp: String {
            // The number of items purchased. This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
            case quantity
            // The product identifier of the item that was purchased. This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
            case productId = "product_id"
            // The transaction identifier of the item that was purchased. This value corresponds to the transaction’s transactionIdentifier property.
            case transactionId = "transaction_id"
            // For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier. This value corresponds to the original transaction’s transactionIdentifier property. All receipts in a chain of renewals for an auto-renewable subscription have the same value for this field.
            case originalTransactionId = "original_transaction_id"
            // The date and time that the item was purchased. This value corresponds to the transaction’s transactionDate property.
            case purchaseDate = "purchase_date"
            // For a transaction that restores a previous transaction, the date of the original transaction. This value corresponds to the original transaction’s transactionDate property. In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renewed.
            case originalPurchaseDate = "original_purchase_date"
            // The expiration date for the subscription, expressed as the number of milliseconds since January 1, 1970, 00:00:00 GMT. This key is only present for auto-renewable subscription receipts.
            case expiresDate = "expires_date"
            // For a transaction that was canceled by Apple customer support, the time and date of the cancellation. Treat a canceled receipt the same as if no purchase had ever been made.
            case cancellationDate = "cancellation_date"
            #if os(iOS) || os(tvOS)
            // A string that the App Store uses to uniquely identify the application that created the transaction. If your server supports multiple applications, you can use this value to differentiate between them. Apps are assigned an identifier only in the production environment, so this key is not present for receipts created in the test environment. This field is not present for Mac apps. See also Bundle Identifier.
            case appItemId = "app_item_id"
            #endif
            // An arbitrary number that uniquely identifies a revision of your application. This key is not present for receipts created in the test environment.
            case versionExternalIdentifier = "version_external_identifier"
            // The primary key for identifying subscription purchases.
            case webOrderLineItemId = "web_order_line_item_id"
        }
    }
}
