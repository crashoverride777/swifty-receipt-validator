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
            let prefix = "SwiftyReceiptValidator "
            
            switch self {
            case .unknown:
                return prefix + "unknown error"
            case .url:
                return prefix + "URL error"
            case .data:
                return prefix + "data error"
            case .json:
                return prefix + "json error"
            case .noStatusCodeFound:
                return prefix + "no status code found"
            case .invalidStatusCode:
                return prefix + "invalid status code"
            case .noReceiptFound:
                return prefix + "no receipt found on device"
            case .noReceiptInJSON:
                return prefix + "no receipt found in json response"
            case .bundleIdNotMatching:
                return prefix + "bundle id is not matching receipt"
            case .productIdNotMatching:
                return prefix + "product id is not matching with receipt"
            case .other(let error):
                return prefix + error.localizedDescription
            }
        }
    }
}
