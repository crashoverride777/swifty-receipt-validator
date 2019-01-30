//
//  SwiftyReceiptValidator+Types.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public extension SwiftyReceiptValidator {
    
    /// The result enum of a validation request. Returns a success or failure case with a corresponding value
    public enum Result<T> {
        case success(T)
        case failure(ValidationError, code: SwiftyReceiptResponse.StatusCode?)
    }
    
    /// The validation mode of the receipt request
    public enum ValidationMode {
        case none
        case purchase(productId: String)
        case subscription
    }
    
    /// Errors
    public enum ValidationError: Error {
        case invalidStatusCode
        case noReceiptFound
        case noReceiptFoundInResponse
        case bundleIdNotMatching
        case productIdNotMatching
        case noValidSubscription
        case other(String)
        
        public var localizedDescription: String {
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
            case .other(let message):
                return message
            }
        }
    }
}
