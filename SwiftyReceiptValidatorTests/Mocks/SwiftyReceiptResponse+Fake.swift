//
//  SwiftyReceiptResponse+Fake.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

extension SwiftyReceiptResponse {
    
    enum JSONType {
        case invalid
        case subscription
        case subscriptionExpired
        
        var name: String {
            switch self {
            case .invalid:
                return "ReceiptResponseInvalidFormat"
            case .subscription:
                return "ReceiptResponseValidSubscription"
            case .subscriptionExpired:
                return "ReceiptResponseSubscriptionExpired"
            }
        }
    }
    
    static func fake(_ type: JSONType) -> SwiftyReceiptResponse {
        guard let path = Bundle(for: MockSessionManager.self).path(forResource: type.name, ofType: "json") else {
            fatalError("Invalid path to JSON file in bundle")
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let receiptResponse = try JSONDecoder().decode(SwiftyReceiptResponse.self, from: data)
            return receiptResponse
        } catch {
            fatalError("SwiftyReceiptResponse fake error \(error)")
        }
    }
}
