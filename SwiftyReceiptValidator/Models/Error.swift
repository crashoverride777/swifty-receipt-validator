//
//  SRVError.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public enum SRVError: LocalizedError {
    case invalidStatusCode(SRVStatusCode)
    case noReceiptFound
    case noReceiptFoundInResponse(SRVStatusCode)
    case bundleIdNotMatching(SRVStatusCode)
    case productIdNotMatching(SRVStatusCode)
    case subscriptionExpired(SRVStatusCode?)
    case cancelled(SRVStatusCode)
    case other(Error)
    
    public var statusCode: SRVStatusCode? {
        switch self {
        case .invalidStatusCode(let statusCode):
            return statusCode
        case .noReceiptFound:
            return nil
        case .noReceiptFoundInResponse(let statusCode):
            return statusCode
        case .bundleIdNotMatching(let statusCode):
            return statusCode
        case .productIdNotMatching(let statusCode):
            return statusCode
        case .subscriptionExpired(let statusCode):
            return statusCode
        case .cancelled(let statusCode):
            return statusCode
        case .other:
            return nil
        }
    }
    
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
        case .subscriptionExpired:
            return LocalizedString.Error.noValidSubscription
        case .cancelled:
            return LocalizedString.Error.cancelled
        case .other(let error):
            return error.localizedDescription
        }
    }
}
