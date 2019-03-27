//
//  SwiftyReceiptResponse.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public struct SwiftyReceiptResponse: Codable {
    // For iOS 6 style transaction receipts, the status code reflects the status of the specific transaction’s receipt.
    // For iOS 7 style app receipts, the status code is reflects the status of the app receipt as a whole. For example, if you send a valid app receipt that contains an expired subscription, the response is 0 because the receipt as a whole is valid.
    public let status: StatusCode
    // A JSON representation of the receipt that was sent for verification. For information about keys found in a receipt, see Receipt Fields.
    public let receipt: SwiftyReceipt?
    // Only returned for receipts containing auto-renewable subscriptions.
    // For iOS 6 style transaction receipts, this is the base-64 encoded receipt for the most recent renewal.
    // For iOS 7 style app receipts, this is the latest base-64 encoded app receipt.
    public let latestReceipt: Data?
    // Only returned for receipts containing auto-renewable subscriptions.
    // For iOS 6 style transaction receipts, this is the JSON representation of the receipt for the most recent renewal.
    // For iOS 7 style app receipts, the value of this key is an array containing all in-app purchase transactions. This excludes transactions for a consumable product that have been marked as finished by your app.
    public let latestReceiptInfo: [SwiftyReceiptInApp]?
    // Only returned for iOS 7 style app receipts containing auto-renewable subscriptions. In the JSON file, the value of this key is an array where each element contains the pending renewal information for each auto-renewable subscription identified by the Product Identifier. A pending renewal may refer to a renewal that is scheduled in the future or a renewal that failed in the past for some reason.
    public let pendingRenewalInfo: [SwiftyReceiptPendingRenewalInfo]?
    // The current environment, Sandbox or Production
    public let environment: String?
}

// MARK: - Status Codes

public extension SwiftyReceiptResponse {
    
    enum StatusCode: Int, Codable {
        case unknown = -1
        case valid = 0
        case jsonNotReadable = 21000
        case malformedOrMissingData = 21002
        case receiptCouldNotBeAuthenticated = 21003
        case sharedSecretNotMatching = 21004
        case receiptServerUnavailable = 21005
        case subscriptionExpired = 21006
        case testReceipt = 21007
        case productionEnvironment = 21008
        case receiptCouldNotBeAuthorized = 21010
        //21100-21199 = Internal data access error.
        
        public init(from decoder: Decoder) throws {
            self = try StatusCode(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
        
        public var description: String {
            switch self {
            case .unknown:
                return "No decodable status"
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
            case .receiptCouldNotBeAuthorized:
                return "This receipt could not be authorized. Treat this the same as if a purchase was never made."
            }
        }
    }
}
