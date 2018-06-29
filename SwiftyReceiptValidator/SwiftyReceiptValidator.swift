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
 
 A class to manage in app purchase receipt validation.
 */
public final class SwiftyReceiptValidator: NSObject {
    public typealias ResultHandler = (Result<[String: AnyObject]>) -> Void
    private typealias ReceiptHandler = (Result<URL>) -> Void
    
    // MARK: - Properties

    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var receiptHandler: ReceiptHandler?
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
  
    // MARK: - Init
    
    public override init() {
        super.init()
        
        print("Init SwiftyReceiptValidator")
    }
    
    // MARK: - Deinit
    
    deinit {
        print("Deinit SwiftyReceiptValidator")
    }
    
    // MARK: - Validate
    
    /// Validate receipt
    ///
    /// Make sure to create a strong/class property to SwiftyReceiptValidator (above init, viewDidLoad etc)
    ///
    /// - parameter productIdentifier: The product Identifier String for the product to validate.
    /// - parameter sharedSecret: The shared secret when using auto-subscriptions.
    /// - result handler: Called when the validation has completed. Will return an result enum with either the receipt date (success) or error (fail).
    public func validate(_ productIdentifier: String, sharedSecret: String?, handler: @escaping ResultHandler) {
        fetchReceipt { result in
           
            switch result {
                
            case .success(let receiptURL):
                do {
                    let receiptData = try Data(contentsOf: receiptURL)
                    self.startValidation(with: receiptData, sharedSecret: sharedSecret, productId: productIdentifier, handler: handler)
                }
                catch {
                    handler(.failure(code: nil, error: .other(error)))
                }
                
            case .failure(let code, let error):
                handler(.failure(code: code, error: .other(error)))
            }
        }
    }
    
    private func fetchReceipt(handler: @escaping (SwiftyReceiptValidator.Result<URL>) -> Void) {
        self.receiptHandler = handler
        
        guard hasReceipt, let receiptURL = receiptURL else {
            let request = SKReceiptRefreshRequest(receiptProperties: nil)
            request.delegate = self
            request.start()
            return
        }
        
        handler(.success(data: receiptURL))
    }
}

// MARK: - SKRequestDelegate

extension SwiftyReceiptValidator: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptHandler?(.failure(code: nil, error: .noReceiptFound))
            return
        }
        
        receiptHandler?(.success(data: receiptURL))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        receiptHandler?(.failure(code: nil, error: .other(error)))
    }
}

// MARK: - Start Receipt Validation

private extension SwiftyReceiptValidator {
    
    func startValidation(with receiptData: Data, sharedSecret: String?, productId: String, handler: @escaping ResultHandler) {
        print("SwiftyReceiptValidator started validation")
        
        // Prepare receipt base 64 string
        let receiptBase64String = receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        // Prepare url session parameters
        var parameters = [JSONObjectKey.receiptData.rawValue: receiptBase64String]
        if let sharedSecret = sharedSecret {
            parameters[JSONObjectKey.password.rawValue] = sharedSecret
        }
      
        // Start URL request to production server first, if it fails because in test environment try sandbox otherwise fail completely.
        // This handles validation directily with apple. This is not the recommended way by apple as it is not secure.
        // It is still better than not doing any validation at all.
        startURLSession(with: .production, parameters: parameters, productId: productId) { result in
            switch result {
                
            case .success(let data):
                print("SwiftyReceiptValidator success (PRODUCTION)")
                handler(.success(data: data))
                
            case .failure(let code, let error):
                // Check if failed production request was due to a test receipt
                guard code == StatusCode.testReceipt.rawValue else {
                    handler(.failure(code: code, error: .other(error)))
                    return
                }
                
                print("SwiftyReceiptValidator validation failed because we are in SANDBOX mode, trying sandbox mode...")
                
                // Handle sandbox request
                self.startURLSession(with: .sandbox, parameters: parameters, productId: productId) { result in
                    switch result {
                    case .success(let data):
                        print("SwiftyReceiptValidator success (SANDBOX)")
                        handler(.success(data: data))
                    case .failure(let code, let error):
                        handler(.failure(code: code, error: .other(error)))
                    }
                }
            }
        }
    }
}

// MARK: - URL Session

private extension SwiftyReceiptValidator {
    
    func startURLSession(with urlString: URLString, parameters: [AnyHashable: Any], productId: String, handler: @escaping ResultHandler) {
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
        let sessionConfiguration: URLSessionConfiguration = .default
        sessionConfiguration.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: sessionConfiguration)
        
        // Start url session
        session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            
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
                strongSelf.validate(jsonData, productId: productId, handler: handler)
            }
                
            catch {
                handler(.failure(code: nil, error: .other(error)))
                return
            }
        }.resume()
    }
}

// MARK: - Validate JSON Data

private extension SwiftyReceiptValidator {
    
    func validate(_ jsonData: [String: AnyObject]?, productId: String, handler: @escaping ResultHandler) {
        // Check that we actually have data
        guard let jsonData = jsonData else {
            handler(.failure(code: nil, error: .json))
            return
        }
        
        // Check for receipt status code in json
        guard let statusCode = jsonData[ResponseKey.status.rawValue] as? Int else {
            handler(.failure(code: nil, error: .noStatusCodeFound))
            return
        }
        
        // Check receipt status is valid
        guard statusCode == StatusCode.valid.rawValue else {
            handler(.failure(code: statusCode, error: .invalidStatusCode))
            return
        }
        
        // Check receipt send for verification exists in json response
        guard let receipt = jsonData[ResponseKey.receipt.rawValue] else {
            handler(.failure(code: statusCode, error: .noReceiptInJSON))
            return
        }
        
        // Check receipt contains correct bundle id
        guard (receipt[InfoKey.bundleId.rawValue] as? String) == Bundle.main.bundleIdentifier else {
            handler(.failure(code: statusCode, error: .bundleIdNotMatching))
            return
        }
        
        // Check receipt contains correct product id
        guard isProductIdentifier(productId, matchingWith: receipt) else {
            handler(.failure(code: statusCode, error: .productIdNotMatching))
            return
        }
        
        // Return success handler
        handler(.success(data: jsonData))
    }
    
    func isProductIdentifier(_ productIdentifier: String, matchingWith receipt: AnyObject) -> Bool {
        guard let inApp = receipt[InfoKey.inApp.rawValue] as? [AnyObject] else { return false }
        return inApp.first(where: { ($0[InfoKey.InApp.productId.rawValue] as? String) == productIdentifier }) != nil
    }
}
