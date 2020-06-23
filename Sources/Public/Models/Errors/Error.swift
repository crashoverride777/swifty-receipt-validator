//
//  SRVError.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public enum SRVError: Error {
    case invalidStatusCode(SRVStatusCode)
    case noReceiptFoundInResponse(SRVStatusCode)
    case bundleIdNotMatching(SRVStatusCode)
    case productIdNotMatching(SRVStatusCode)
    case subscriptioniOS6StyleExpired(SRVStatusCode?)
    case cancelled(SRVStatusCode)
    case other(Error)
    
    public var statusCode: SRVStatusCode? {
        switch self {
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
        case .cancelled(let statusCode):
            return statusCode
        case .other:
            return nil
        }
    }
}
