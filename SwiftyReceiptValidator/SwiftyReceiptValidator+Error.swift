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
        case appBundleIDNotMatching
        case other(Error)
        
        var localizedDescription: String {
            switch self {
            case .unknown:
                return "SwiftyReceiptValidator unknown error"
            case .url:
                return "SwiftyReceiptValidator URL error"
            case .data:
                return "SwiftyReceiptValidator data error"
            case .json:
                return "SwiftyReceiptValidator json error"
            case .noStatusCodeFound:
                return "SwiftyReceiptValidator no status code found"
            case .invalidStatusCode:
                return "SwiftyReceiptValidator invalid status code"
            case .noReceiptFound:
                return "SwiftyReceiptValidator no receipt found on device"
            case .noReceiptInJSON:
                return "SwiftyReceiptValidator no receipt found in json response"
            case .appBundleIDNotMatching:
                return "SwiftyReceiptValidator app bundle id is not matching"
            case .other(let error):
                return error.localizedDescription
            }
        }
    }
}
