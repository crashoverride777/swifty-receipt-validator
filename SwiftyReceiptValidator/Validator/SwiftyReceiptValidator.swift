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
 */
public final class SwiftyReceiptValidator: NSObject {
   
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

    let configuration: Configuration
    let receiptFetcher: SRVBundleReceiptFetcherType
    let sessionManager: SRVURLSessionManagerType
    let validator: SRVResponseValidatorType

    // MARK: - Init
    
    /// Init
    ///
    /// - parameter configuration: The configuration struct to customise SwiftyReceiptValidator.
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.receiptFetcher = SRVBundleReceiptFetcher()
        self.sessionManager = SRVURLSessionManager(sessionConfiguration: configuration.sessionConfiguration)
        self.validator = SRVResponseValidator()
    }
    
    // Internal for testing
    init(configuration: Configuration,
         receiptFetcher: SRVBundleReceiptFetcherType,
         sessionManager: SRVURLSessionManagerType,
         validator: SRVResponseValidatorType) {
        self.configuration = configuration
        self.receiptFetcher = receiptFetcher
        self.sessionManager = sessionManager
        self.validator = validator
    }
    
    // MARK: - Deinit
    
    deinit {
        print("Deinit SwiftyReceiptValidator")
    }
}
