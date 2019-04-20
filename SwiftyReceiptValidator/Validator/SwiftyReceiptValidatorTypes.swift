//
//  SwiftyReceiptValidator+Types.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

/// The result enum of a validation request. Returns a success or failure case with a corresponding value
public enum SwiftyReceiptValidatorResult<T> {
    case success(T)
    case failure(SwiftyReceiptValidatorError, code: SwiftyReceiptResponse.StatusCode?)
}

/// Errors
public enum SwiftyReceiptValidatorError: LocalizedError {
    case invalidStatusCode
    case noReceiptFound
    case noReceiptFoundInResponse
    case bundleIdNotMatching
    case productIdNotMatching
    case noValidSubscription
    case cancelled
    case other(String)
    
    #warning("Translate")
    public var errorDescription: String? {
        switch self {
        case .invalidStatusCode:
            return "SwiftyReceiptValidator Invalid status code"
        case .noReceiptFound:
            return "SwiftyReceiptValidator No receipt found on device"
        case .noReceiptFoundInResponse:
            return "SwiftyReceiptValidator No receipt found in server response"
        case .bundleIdNotMatching:
            return "SwiftyReceiptValidator Bundle id is not matching receipt"
        case .productIdNotMatching:
            return "SwiftyReceiptValidator Product id is not matching with receipt"
        case .noValidSubscription:
            return "SwiftyReceiptValidator No active subscription found"
        case .cancelled:
            return "Cancelled"
        case .other(let description):
            return description
        }
    }
}
