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
    public typealias ResultHandler = (SwiftyReceiptResult<SwiftyReceiptResponse>) -> Void
    private typealias ReceiptHandler = (SwiftyReceiptResult<URL>) -> Void
    
    // MARK: - Types
    
    /// The result enum of a validation request. Returns a success or failure case with a corresponding value
    public enum SwiftyReceiptResult<T> {
        case success(T)
        case failure(ValidationError, code: SwiftyReceiptResponse.StatusCode?)
    }
    
    /// The validation mode of the receipt request
    public enum ValidationMode {
        case none
        case purchase(productId: String)
        case subscription
    }
    
    // MARK: - Properties

    let sessionManager = SessionManager()
    
    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var receiptHandler: ReceiptHandler?
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
    
    private(set) lazy var jsonDecoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
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
    
    // MARK: - Validate Receipt
    
    /// Validate app store receipt
    ///
    /// - parameter validationMode: The validation method of receipt request.
    /// - parameter sharedSecret: The shared secret when using auto-subscriptions.
    /// - result handler: Called when the validation has completed. Will return an result enum with success or failure.
    public func validate(_ validationMode: ValidationMode, sharedSecret: String?, handler: @escaping ResultHandler) {
        fetchReceipt { result in
            switch result {
            case .success(let receiptURL):
                do {
                    let receiptData = try Data(contentsOf: receiptURL)
                    self.startURLSession(with: receiptData,
                                         sharedSecret: sharedSecret,
                                         validationMode: validationMode,
                                         handler: handler)
                } catch {
                    handler(.failure(.other(error.localizedDescription), code: nil))
                }
            case .failure(let error, let code):
                handler(.failure(error, code: code))
            }
        }
    }
    
    private func fetchReceipt(handler: @escaping (SwiftyReceiptResult<URL>) -> Void) {
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
        receiptHandler?(.failure(.other(error.localizedDescription), code: nil))
    }
}
