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

import Combine
import StoreKit

/*
 SwiftyReceiptValidator
 
 A concrete implementation of SwiftyReceiptValidatorType to manage in app purchase receipt validation
 */
public final class SwiftyReceiptValidator: NSObject {
   
    // MARK: - Types
    
    public struct Configuration {
        let productionURL: String
        let sandboxURL: String
        let sessionConfiguration: URLSessionConfiguration
        
        /// Init
        ///
        /// - parameter productionURL: The production url of the server to validate the receipt with.
        /// - parameter sandboxURL: The sandbox url of the server to validate the receipt with.
        /// - parameter sessionConfiguration: The URLSessionConfiguration to make URL requests.
        public init(productionURL: String, sandboxURL: String, sessionConfiguration: URLSessionConfiguration) {
            self.productionURL = productionURL
            self.sandboxURL = sandboxURL
            self.sessionConfiguration = sessionConfiguration
        }
        
        /// Standard validation configuration
        /// Validates directy with apple servers which is not recommended
        public static let standard = Configuration(
            productionURL: "https://buy.itunes.apple.com/verifyReceipt",
            sandboxURL: "https://sandbox.itunes.apple.com/verifyReceipt",
            sessionConfiguration: .default
        )
    }
    
    // MARK: - Properties

    let configuration: Configuration
    let receiptFetcher: BundleReceiptFetcherType
    let sessionManager: URLSessionManagerType
    let validator: ResponseValidatorType
    private let isLoggingEnabled: Bool
    
    // MARK: - Init
    
    /// Init
    ///
    /// - parameter configuration: The configuration needed for SwiftyReceiptValidator.
    /// - parameter isLoggingEnabled: Display logging events if true. Defaults to false.
    public init(configuration: Configuration, isLoggingEnabled: Bool = false) {
        self.configuration = configuration
        self.receiptFetcher = BundleReceiptFetcher()
        self.sessionManager = URLSessionManager(sessionConfiguration: configuration.sessionConfiguration)
        self.validator = ResponseValidator()
        self.isLoggingEnabled = isLoggingEnabled
    }
    
    // Internal for testing
    init(configuration: Configuration,
         receiptFetcher: BundleReceiptFetcherType,
         sessionManager: URLSessionManagerType,
         validator: ResponseValidatorType) {
        self.configuration = configuration
        self.receiptFetcher = receiptFetcher
        self.sessionManager = sessionManager
        self.validator = validator
        self.isLoggingEnabled = false
    }
    
    // MARK: - Deinit
    
    deinit {
        print("Deinit SwiftyReceiptValidator")
    }
}

// MARK: - Print

extension SwiftyReceiptValidator {
    
    func print(_ items: Any...) {
        guard isLoggingEnabled else {
            return
        }
        Swift.print(items[0])
    }
}
