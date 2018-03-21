//
//  SwiftyReceiptValidator+Error.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

//    The MIT License (MIT)
//
//    Copyright (c) 2016-2018 Dominik Ringler
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation

/// SwiftyReceiptValidator validation errors
public extension SwiftyReceiptValidator {
    
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
