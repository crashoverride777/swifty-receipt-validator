//
//  SRVError.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public enum SRVError: LocalizedError {
    case invalidStatusCode(SRVReceiptResponse.StatusCode)
    case noReceiptFound
    case noReceiptFoundInResponse(SRVReceiptResponse.StatusCode)
    case bundleIdNotMatching(SRVReceiptResponse.StatusCode)
    case productIdNotMatching(SRVReceiptResponse.StatusCode)
    case noValidSubscription(SRVReceiptResponse.StatusCode?)
    case cancelled(SRVReceiptResponse.StatusCode)
    case other(Error)
    
    public var statusCode: SRVReceiptResponse.StatusCode? {
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
        case .noValidSubscription(let statusCode):
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
        case .noValidSubscription:
            return LocalizedString.Error.noValidSubscription
        case .cancelled:
            return LocalizedString.Error.cancelled
        case .other(let error):
            return error.localizedDescription
        }
    }
}
