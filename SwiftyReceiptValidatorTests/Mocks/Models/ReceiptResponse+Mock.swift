//
//  ReceiptResponse+Mock.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 25/11/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

extension SRVReceiptResponse {
    
    enum JSONType {
        case invalid
        case subscription
        case subscriptionExpired
        case sandbox
        
        var name: String {
            switch self {
            case .invalid:
                return "ReceiptResponseInvalidFormat"
            case .subscription:
                return "ReceiptResponseValidSubscription"
            case .subscriptionExpired:
                return "ReceiptResponseSubscriptionExpired"
            case .sandbox:
                return "ReceiptResponseSandbox"
            }
        }
    }
    
    static func mock(
        statusCode: SRVStatusCode = .valid,
        receipt: SRVReceipt? = .mock(),
        latestReceipt: Data? = nil,
        latestReceiptInfo: [SRVReceiptInApp]? = [.mock()],
        pendingRenewalInfo: [SRVPendingRenewalInfo]? = [.mock()],
        environment: String? = nil) -> SRVReceiptResponse {
        SRVReceiptResponse(
            status: statusCode,
            receipt: receipt,
            latestReceipt: latestReceipt,
            latestReceiptInfo: latestReceiptInfo,
            pendingRenewalInfo: pendingRenewalInfo,
            environment: environment
        )
    }
    
    static func mock(_ type: JSONType) -> [String: Any] {
        guard let path = Bundle(for: MockSessionManager.self).path(forResource: type.name, ofType: "json") else {
            fatalError("Invalid path to JSON file in bundle")
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: [])
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                fatalError("Invalid jsob object")
            }
            return dictionary
        } catch {
            fatalError("SwiftyReceiptResponse fake error \(error)")
        }
    }
    
    static func mock(from dictionary: [String: Any]) -> SRVReceiptResponse {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let decoder: JSONDecoder = .receiptResponse
            let receiptResponse = try decoder.decode(SRVReceiptResponse.self, from: data)
            return receiptResponse
        } catch {
            fatalError("SwiftyReceiptResponse fake error \(error)")
        }
    }
}
