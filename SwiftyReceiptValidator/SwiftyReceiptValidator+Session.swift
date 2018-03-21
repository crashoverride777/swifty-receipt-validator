//
//  SwiftyReceiptValidator+Session.swift
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

private enum HTTPMethod: String {
    case post = "POST"
}

extension SwiftyReceiptValidator {
    
    static func startURLSession(with urlString: URLString, parameters: [AnyHashable: Any], productId: String, handler: @escaping ResultHandler) {
        
        // Create url
        guard let url = URL(string: urlString.rawValue) else {
            handler(.failure(code: nil, error: .url))
            return
        }
        
        // Setup url request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // Setup session
        let sessionConfiguration = URLSessionConfiguration()
        sessionConfiguration.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: sessionConfiguration)
        
        // Start url session
        session.dataTask(with: urlRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                handler(.failure(code: nil, error: .other(error)))
                return
            }
            
            // Unwrap data
            guard let data = data else {
                handler(.failure(code: nil, error: .data))
                return
            }
            
            // Parse json
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: AnyObject]
                validate(jsonData, productId: productId, handler: handler)
            }
            
            catch let error {
                handler(.failure(code: nil, error: .other(error)))
                return
            }
        }.resume()
    }
}

// MARK: - Validate JSON Data

private extension SwiftyReceiptValidator {
    
    static func validate(_ jsonData: [String: AnyObject]?, productId: String, handler: @escaping ResultHandler) {
        
        // Check that we actually have data
        guard let jsonData = jsonData else {
            handler(.failure(code: nil, error: .json))
            return
        }
        // Check for receipt status in json
        guard let status = jsonData[ResponseKey.status.rawValue] as? Int else {
            handler(.failure(code: nil, error: .noStatusCodeFound))
            return
        }
        
        // Check receipt status is valid
        guard status == StatusCode.valid.rawValue else {
            handler(.failure(code: status, error: .invalidStatusCode))
            return
        }
        
        // Check receipt send for verification exists in json response
        guard let receipt = jsonData[ResponseKey.receipt.rawValue] else {
            handler(.failure(code: nil, error: .noReceiptInJSON))
            return
        }
        
        // Check receipt contains correct bundle id
        guard self.isBundleIdentifierMatching(with: receipt) else {
            handler(.failure(code: status, error: .bundleIdNotMatching))
            return
        }
        
        // Check receipt contains correct product id
        guard self.isProductIdentifier(productId, matchingWith: receipt) else {
            handler(.failure(code: status, error: .productIdNotMatching))
            return
        }
        
        // Return success handler
        handler(.success(data: jsonData))
    }
    
    static func isBundleIdentifierMatching(with receipt: AnyObject) -> Bool {
        return (receipt[InfoKey.bundle_id.rawValue] as? String) == Bundle.main.bundleIdentifier
    }
    
    static func isProductIdentifier(_ productIdentifier: String, matchingWith receipt: AnyObject) -> Bool {
        guard let inApp = receipt[InfoKey.in_app.rawValue] as? [AnyObject] else { return false }
        return inApp.first(where: { ($0[InfoKey.InApp.product_id.rawValue] as? String) == productIdentifier }) != nil
    }
}
