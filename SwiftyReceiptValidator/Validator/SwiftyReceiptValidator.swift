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
    public typealias ResultHandler = (Result<SwiftyReceiptResponse>) -> Void
    private typealias ReceiptHandler = (Result<URL>) -> Void
    
    // MARK: - Types
    
    public enum ValidationMode {
        case none
        case product(productId: String)
        case subscription
    }
    
    // MARK: - Properties

    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var receiptHandler: ReceiptHandler?
    
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    private var session: URLSession?
    
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
    
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.receipt)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
  
    // MARK: - Init
    
    public override init() {
        super.init()
        
        print("Init SwiftyReceiptValidator")
    }
    
    // MARK: - Deinit
    
    deinit {
        print("Deinit SwiftyReceiptValidator")
    }
    
    // MARK: - Get Validated Receipt
    
    /// Get validated app store receipt
    ///
    /// - parameter sharedSecret: The shared secret when using auto-subscriptions.
    /// - parameter validationMode: The method of receipt validation.
    /// - result handler: Called when the validation has completed. Will return an result enum with success or failure.
    func getValidatedReceipt(sharedSecret: String?, validationMode: ValidationMode, handler: @escaping ResultHandler) {
        fetchReceipt { result in
            switch result {
            case .success(let receiptURL):
                do {
                    let receiptData = try Data(contentsOf: receiptURL)
                    self.validateReceipt(with: receiptData,
                                         sharedSecret: sharedSecret,
                                         validationMode: validationMode,
                                         handler: handler)
                } catch {
                    handler(.failure(.other(error), code: nil))
                }
            case .failure(let error, let code):
                handler(.failure(.other(error), code: code))
            }
        }
    }
    
    private func fetchReceipt(handler: @escaping (SwiftyReceiptValidator.Result<URL>) -> Void) {
        self.receiptHandler = handler
        
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            receiptRefreshRequest?.delegate = self
            receiptRefreshRequest?.start()
            return
        }
        
        handler(.success(receiptURL))
    }
}

// MARK: - SKRequestDelegate

extension SwiftyReceiptValidator: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptHandler?(.failure(.noReceiptFound, code: nil))
            return
        }
        
        receiptHandler?(.success(receiptURL))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        receiptHandler?(.failure(.other(error), code: nil))
    }
}

// MARK: - Start Receipt Validation

private extension SwiftyReceiptValidator {
    
    func validateReceipt(with receiptData: Data, sharedSecret: String?, validationMode: ValidationMode, handler: @escaping ResultHandler) {
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
        startURLSession(with: .production, parameters: parameters, validationMode: validationMode) { result in
            switch result {
                
            case .success(let data):
                print("SwiftyReceiptValidator success (PRODUCTION)")
                handler(.success(data))
                
            case .failure(let error, let code):
                // Check if failed production request was due to a test receipt
                guard code == StatusCode.testReceipt.rawValue else {
                    handler(.failure(.other(error), code: code))
                    return
                }
                
                print("SwiftyReceiptValidator validation failed because we are in Production mode, trying sandbox mode...")
                
                // Handle sandbox request
                self.startURLSession(with: .sandbox, parameters: parameters, validationMode: validationMode) { result in
                    switch result {
                    case .success(let data):
                        print("SwiftyReceiptValidator success (SANDBOX)")
                        handler(.success(data))
                    case .failure(let error, let code):
                        handler(.failure(.other(error), code: code))
                    }
                }
            }
        }
    }
}

// MARK: - URL Session

private extension SwiftyReceiptValidator {
    
    func startURLSession(with urlString: URLString,
                         parameters: [AnyHashable: Any],
                         validationMode: ValidationMode,
                         handler: @escaping ResultHandler) {
        // Create url
        #if DEBUG
        let urlString: URLString = .sandbox
        #endif
        guard let url = URL(string: urlString.rawValue) else {
            handler(.failure(.url, code: nil))
            return
        }
        
        // Setup url request
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // Setup session
        let sessionConfiguration: URLSessionConfiguration = .default
        sessionConfiguration.timeoutIntervalForRequest = 20.0
        session = URLSession(configuration: sessionConfiguration)
        
        // Start url session
        session?.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            // Check for error
            if let error = error {
                handler(.failure(.other(error), code: nil))
                return
            }
            
            // Unwrap data
            guard let data = data else {
                handler(.failure(.data, code: nil))
                return
            }
            
            // Parse json
            do {
                let response = try self.jsonDecoder.decode(SwiftyReceiptResponse.self, from: data)
                self.validate(response, validationMode: validationMode, handler: handler)
            } catch {
                handler(.failure(.other(error), code: nil))
                return
            }
        }.resume()
    }
}

// MARK: - Validation

private extension SwiftyReceiptValidator {
    
    func validate(_ response: SwiftyReceiptResponse, validationMode: ValidationMode, handler: @escaping ResultHandler) {
        // Check receipt status is valid
        guard response.status == StatusCode.valid.rawValue else {
            handler(.failure(.invalidStatusCode, code: response.status))
            return
        }
        
        // Check receipt contains correct bundle id
        guard response.receipt.bundleId == Bundle.main.bundleIdentifier else {
            handler(.failure(.bundleIdNotMatching, code: response.status))
            return
        }
        
        // Run the validation for the correct mode
        switch validationMode {
        case .none:
            break
            
        case .product(let productId):
            // Check a valid receipt with matching product id was found
            guard response.receipt.inApp.first(where: { $0.productId == productId }) != nil else {
                handler(.failure(.productIdNotMatching, code: response.status))
                return
            }
            
        case .subscription:
            var receipts = response.latestReceipt?.inApp ?? response.receipt.inApp
            receipts.removeAll {
                guard let expiresDate = $0.expiresDate else { return true }
                return expiresDate < Date()
            }
            
            guard !receipts.isEmpty else {
                handler(.failure(.noValidSubscription, code: response.status))
                return
            }
        }
        
        // Return success handler
        handler(.success(response))
    }
}

