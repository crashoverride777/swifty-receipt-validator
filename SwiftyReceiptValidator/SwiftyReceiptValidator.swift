//
//  SwiftyReceiptValidator.swift
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

import StoreKit

/*
 SwiftyReceiptValidator
 
 An enum to manage in app purchase receipt validation.
 */
public final class SwiftyReceiptValidator: NSObject {
    public typealias ResultHandler = (Result<[String: AnyObject]>) -> Void
    
    // MARK: - Types
    
    /// The result enum of a validation request. Returns a success of failure case with a corresponding value
    public enum Result<T> {
        case success(data: T)
        case failure(code: Int?, error: ValidationError)
    }
    
    /// The urls of the sandbox or production apple server.
    public enum URLString: String {
        case sandbox    = "https://sandbox.itunes.apple.com/verifyReceipt"
        case production = "https://buy.itunes.apple.com/verifyReceipt"
    }
    
    /// JSON keys
    private enum JSONObjectKey: String {
        case receiptData = "receipt-data"
        case password
    }
    
    // MARK: - Properties
    
    private let receiptObtainer = SwiftyReceiptObtainer()
    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
    
    // MARK: - Start
    
    /// Validate receipt
    ///
    /// - parameter productIdentifier: The product Identifier String for the product to validate.
    /// - parameter sharedSecret: The shared secret when using auto-subscriptions.
    /// - result handler: Called when the validation has completed. Will return the success state of the validation and an optional dictionary for further receipt validation if successfull.
    public func start(withProductId productIdentifier: String, sharedSecret: String?, handler: @escaping ResultHandler) {
        receiptObtainer.fetch { result in
           
            switch result {
                
            case .success(let receiptURL):
                do {
                    let receiptData = try Data(contentsOf: receiptURL)
                    self.startValidation(with: receiptData, secret: sharedSecret, productId: productIdentifier, handler: handler)
                }
                    
                catch let error {
                    handler(.failure(code: nil, error: .other(error)))
                }
                
            case .failure(let error):
                handler(.failure(code: nil, error: .other(error.error)))
            }
        }
    }
}

// MARK: - Start Receipt Validation

private extension SwiftyReceiptValidator {
    
    func startValidation(with receiptData: Data, secret: String?, productId: String, handler: @escaping ResultHandler) {
        
        // Prepare receipt base 64 string
        let receiptBase64String = receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        // Prepare url session parameters
        var parameters = [JSONObjectKey.receiptData.rawValue: receiptBase64String]
        
        // Add shared secret to url session parameters if needed
        if let sharedSecret = secret {
            parameters[JSONObjectKey.password.rawValue] = sharedSecret
        }
      
        // Start URL request to production server first, if it fails because in test environment try sandbox other fail completely.
        // This handles validation directily with apple. This is not the recommended way by apple as it is not secure.
        // It is still better than not doing any validation at all.
        startURLSession(with: .production, parameters: parameters, productId: productId) { result in
            switch result {
                
            case .success(let data):
                handler(.success(data: data))
                
            case .failure(let code, let error):
                // Check if failed production request was due to a test receipt
                guard code == StatusCode.testReceipt.rawValue else {
                    handler(.failure(code: code, error: .other(error)))
                    return
                }
                
                // Handle sandbox request
                self.startURLSession(with: .sandbox, parameters: parameters, productId: productId) { result in
                    switch result {
                    case .success(let data):
                        handler(.success(data: data))
                    case .failure(let code, let error):
                        handler(.failure(code: code, error: .other(error)))
                    }
                }
            }
        }
    }
}
