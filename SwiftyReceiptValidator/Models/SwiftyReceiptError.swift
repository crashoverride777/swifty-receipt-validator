//
//  SwiftyReceiptError.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public enum SwiftyReceiptError: Error {
    case url
    case data
    case json
    case invalidStatusCode
    case noReceiptFound
    case bundleIdNotMatching
    case productIdNotMatching
    case noValidSubscription
    case other(String)
    
    public var localizedDescription: String {
        switch self {
        case .url:
            return "SwiftyReceiptValidator URL error"
        case .data:
            return "SwiftyReceiptValidator Data error"
        case .json:
            return "SwiftyReceiptValidator JSON error"
        case .invalidStatusCode:
            return "SwiftyReceiptValidator Invalid status code"
        case .noReceiptFound:
            return "SwiftyReceiptValidator No receipt found on device"
        case .bundleIdNotMatching:
            return "SwiftyReceiptValidator Bundle id is not matching receipt"
        case .productIdNotMatching:
            return "SwiftyReceiptValidator Product id is not matching with receipt"
        case .noValidSubscription:
            return "SwiftyReceiptValidator No active subscription found"
        case .other(let message):
            return message
        }
    }
}
