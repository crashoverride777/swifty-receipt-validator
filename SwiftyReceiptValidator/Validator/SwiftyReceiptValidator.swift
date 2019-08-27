//
//  SwiftyReceiptValidator.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2016-2019 Dominik Ringler
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import StoreKit

public protocol SwiftyReceiptValidatorType: class {
    func validatePurchase(forProductId productId: String,
                          in response: SwiftyReceiptResponse,
                          handler: @escaping SwiftyReceiptValidator.ResultHandler)
    func validateSubscription(in response: SwiftyReceiptResponse, handler: @escaping SwiftyReceiptValidator.ResultHandler)
}


/*
 SwiftyReceiptValidator
 
 A class to manage in app purchase receipt validation.
 */
public final class SwiftyReceiptValidator: NSObject {
    public typealias ResultHandler = (Result<SwiftyReceiptResponse, SwiftyReceiptValidatorError>) -> Void
    
    // MARK: - Types
    
    public struct Configuration {
        let productionURL: String
        let sandboxURL: String
        let sessionConfiguration: URLSessionConfiguration
        
        public init(productionURL: String, sandboxURL: String, sessionConfiguration: URLSessionConfiguration) {
            self.productionURL = productionURL
            self.sandboxURL = sandboxURL
            self.sessionConfiguration = sessionConfiguration
        }
        
        /// Defaults to apple validation only which is not recommended
        public static var standard: Configuration {
            return Configuration(productionURL: "https://buy.itunes.apple.com/verifyReceipt",
                                 sandboxURL: "https://sandbox.itunes.apple.com/verifyReceipt",
                                 sessionConfiguration: .default)
        }
    }
    
    // MARK: - Properties

    let sessionManager: URLSessionManagerType
    let configuration: Configuration
    let receiptFetcher = SwiftyReceiptFetcher()
    let validator: SwiftyReceiptValidatorType
    
    // MARK: - Init
    
    /// Init
    ///
    /// - parameter configuration: The configuration struct to customise SwiftyReceiptValidator.
    /// - parameter sessionManager: The URL session manager. Defaults to nil (default).
    /// - parameter validator: The validator handles purchase/subscription validation. Defaults to nil (default).
    public init(configuration: Configuration,
                sessionManager: URLSessionManagerType? = nil,
                validator: SwiftyReceiptValidatorType? = nil) {
        self.configuration = configuration
        self.sessionManager = sessionManager ?? URLSessionManager(sessionConfiguration: configuration.sessionConfiguration)
        self.validator = validator ?? DefaultValidator()
    }
    
    // MARK: - Deinit
    
    deinit {
        print("Deinit SwiftyReceiptValidator")
    }
    
    // MARK: - Validate Purchase
    
    /// Validate app store purchase
    ///
    /// - parameter productId: The id of the purchase to verify.
    /// - parameter handler: Completion handler called when the validation has completed.
    func validatePurchase(withId productId: String, handler: @escaping ResultHandler) {
        start(sharedSecret: nil, excludeOldTransactions: false) { [weak self] result in
            switch result {
            case .success(let response):
                self?.validator.validatePurchase(forProductId: productId, in: response, handler: handler)
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    // MARK: - Validate Subscription
    
    /// Validate app store subscription
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter handler: Completion handler called when the validation has completed.
    func validateSubscription(sharedSecret: String?, excludeOldTransactions: Bool, handler: @escaping ResultHandler) {
        start(sharedSecret: sharedSecret, excludeOldTransactions: excludeOldTransactions) { [weak self] result in
            switch result {
            case .success(let response):
                self?.validator.validateSubscription(in: response, handler: handler)
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

// MARK: - Private Methods

private extension SwiftyReceiptValidator {
    
    func start(sharedSecret: String?, excludeOldTransactions: Bool, handler: @escaping ResultHandler) {
        receiptFetcher.fetch { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let receiptURL):
                do {
                    let receiptData = try Data(contentsOf: receiptURL)
                    self.startURLSession(
                        with: receiptData,
                        sharedSecret: sharedSecret,
                        excludeOldTransactions: excludeOldTransactions,
                        handler: handler
                    )
                } catch {
                    self.printError(error)
                    handler(.failure(.other(error)))
                }
            case .failure(let error):
                self.printError(error)
                handler(.failure(error))
            }
        }
    }
}

// MARK: - Debug

extension SwiftyReceiptValidator {
    
    func printError(_ error: Error) {
        #if DEBUG
        print("SwiftyReceiptValidator error: \(error)")
        #endif
    }
}
