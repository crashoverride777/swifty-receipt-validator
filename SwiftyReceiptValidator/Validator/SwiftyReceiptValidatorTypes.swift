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
    
    public var errorDescription: String? {
        switch self {
        case .invalidStatusCode:
            return LocalizedString.Error.invalidStatusCode
        case .noReceiptFound:
            return LocalizedString.Error.noReceiptFound
        case .noReceiptFoundInResponse:
            return LocalizedString.Error.noReceiptFoundInResponse
        case .bundleIdNotMatching:
            return LocalizedString.Error.bundleIdNotMatching
        case .productIdNotMatching:
            return LocalizedString.Error.productIdNotMatching
        case .noValidSubscription:
            return LocalizedString.Error.noValidSubscription
        case .cancelled:
            return LocalizedString.Error.cancelled
        case .other(let description):
            return description
        }
    }
}
