//
//  SwiftyReceiptValidator+Session.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

import Foundation

private enum HTTPMethod: String {
    case post = "POST"
}

extension SwiftyReceiptValidator {
    typealias URLSessionHandler = (Result<[String: AnyObject]>) -> Void
    
    static func startURLSession(with urlString: URLString, parameters: [AnyHashable: Any], handler: @escaping URLSessionHandler) {
        
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
            if let error = error {
                handler(.failure(code: nil, error: .other(error)))
                return
            }
            
            // Data unwrapping error
            guard let data = data else {
                handler(.failure(code: nil, error: .data))
                return
            }
            
            // Parse json
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String : AnyObject] else {
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
                
                // Check receipt contains correct bundle and product id for app
                guard self.isAppBundleIDMatching(withReceipt: receipt) && self.isTransactionProductIDMatching(withReceipt: receipt) else {
                    handler(.failure(code: status, error: .appBundleIDNotMatching))
                    return
                }
                
                // Return success for basic validation
                handler(.success(data: jsonData))
            }
            
            catch let error {
                handler(.failure(code: nil, error: .other(error)))
                return
            }
        }.resume()
    }
}

// MARK: - Receipt Validation Basic Checks

private extension SwiftyReceiptValidator {
    
    static func isAppBundleIDMatching(withReceipt receipt: AnyObject) -> Bool {
        guard
            let receiptBundleID = receipt[InfoKey.bundle_id.rawValue] as? String,
            let appBundleID = Bundle.main.bundleIdentifier else {
            return false
        }
        return receiptBundleID == appBundleID
    }
    
    static func isTransactionProductIDMatching(withReceipt receipt: AnyObject) -> Bool {
        guard let inApp = receipt[InfoKey.in_app.rawValue] as? [AnyObject] else { return false }
        
        for receiptInApp in inApp where (receiptInApp[InfoKey.InApp.product_id.rawValue] as? String) == productIdentifier {
            return true
        }
        return false
    }
}
