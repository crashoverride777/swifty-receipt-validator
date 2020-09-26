//
//  SRVError.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public enum SRVError: Error {
    case noReceiptFoundInBundle
    case invalidStatusCode(SRVStatusCode)
    case noReceiptFoundInResponse(SRVStatusCode)
    case bundleIdNotMatching(SRVStatusCode)
    case productIdNotMatching(SRVStatusCode)
    case subscriptioniOS6StyleExpired(SRVStatusCode?)
    case purchaseCancelled(SRVStatusCode)
    case other(Error)
    
    public var statusCode: SRVStatusCode? {
        switch self {
        case .noReceiptFoundInBundle:
            return nil
        case .invalidStatusCode(let statusCode):
            return statusCode
        case .noReceiptFoundInResponse(let statusCode):
            return statusCode
        case .bundleIdNotMatching(let statusCode):
            return statusCode
        case .productIdNotMatching(let statusCode):
            return statusCode
        case .subscriptioniOS6StyleExpired(let statusCode):
            return statusCode
        case .purchaseCancelled(let statusCode):
            return statusCode
        case .other:
            return nil
        }
    }
}

// MARK: - LocalizedError

extension SRVError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .noReceiptFoundInBundle:
            return LocalizedString.Error.noReceiptFoundInBundle
        case .invalidStatusCode(let statusCode):
            return LocalizedString.Error.invalidStatusCode(statusCode.rawValue)
        case .noReceiptFoundInResponse:
            return LocalizedString.Error.noReceiptFoundInResponse
        case .bundleIdNotMatching:
            return LocalizedString.Error.bundleIdNotMatching
        case .productIdNotMatching:
            return LocalizedString.Error.productIdNotMatching
        case .subscriptioniOS6StyleExpired:
            return LocalizedString.Error.subscriptioniOS6StyleExpired
        case .purchaseCancelled:
            return LocalizedString.Error.purchaseCancelled
        case .other(let error):
            return error.localizedDescription
        }
    }
}
