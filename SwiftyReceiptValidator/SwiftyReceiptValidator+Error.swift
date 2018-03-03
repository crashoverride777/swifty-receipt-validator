//
//  SwiftyReceiptValidator+Error.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

import Foundation

extension SwiftyReceiptValidator {
    
    public enum ValidationError: Error {
        case unknown
        case url
        case data
        case json
        case noStatusCodeFound
        case invalidStatusCode
        case noReceiptFound
        case noReceiptInJSON
        case bundleIdNotMatching
        case productIdNotMatching
        case other(Error)
        
        var localizedDescription: String {
            let message: String
            
            switch self {
            case .unknown:
                message = "unknown error"
            case .url:
                message = "URL error"
            case .data:
                message = "data error"
            case .json:
                message = "json error"
            case .noStatusCodeFound:
                message = "no status code found"
            case .invalidStatusCode:
                message = "invalid status code"
            case .noReceiptFound:
                message = "no receipt found on device"
            case .noReceiptInJSON:
                message = "no receipt found in json response"
            case .bundleIdNotMatching:
                message = "bundle id is not matching receipt"
            case .productIdNotMatching:
                message = "product id is not matching with receipt"
            case .other(let error):
                message = error.localizedDescription
            }
            return "SwiftyReceiptValidator " + message
        }
    }
}
