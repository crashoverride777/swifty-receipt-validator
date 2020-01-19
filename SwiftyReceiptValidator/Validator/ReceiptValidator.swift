//
//  ReceiptValidator.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2016-2020 Dominik Ringler
 
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
   
    // MARK: - Properties

    let configuration: SRVConfiguration
    let receiptURLFetcher: ReceiptURLFetcherType
    let receiptClient: ReceiptClientType
    let responseValidator: ResponseValidatorType
    private let isLoggingEnabled: Bool
    
    // MARK: - Init
    
    /// Init
    ///
    /// - parameter configuration: The configuration needed for SwiftyReceiptValidator.
    /// - parameter isLoggingEnabled: Displays console logging events if set to true.
    public init(configuration: SRVConfiguration, isLoggingEnabled: Bool) {
        self.configuration = configuration
        self.receiptURLFetcher = ReceiptURLFetcher(
            appStoreReceiptURL: { Bundle.main.appStoreReceiptURL },
            fileManager: .default
        )
        self.receiptClient = ReceiptClient(
            productionURL: configuration.productionURL,
            sandboxURL: configuration.sandboxURL,
            sessionManager: URLSessionManager(sessionConfiguration: configuration.sessionConfiguration),
            isLoggingEnabled: isLoggingEnabled
        )
        self.responseValidator = ResponseValidator(
            bundle: .main,
            isLoggingEnabled: isLoggingEnabled
        )
        self.isLoggingEnabled = isLoggingEnabled
    }
    
    // Internal only (testing)
    init(configuration: SRVConfiguration,
         receiptURLFetcher: ReceiptURLFetcherType,
         receiptClient: ReceiptClientType,
         responseValidator: ResponseValidatorType) {
        self.configuration = configuration
        self.receiptURLFetcher = receiptURLFetcher
        self.receiptClient = receiptClient
        self.responseValidator = responseValidator
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
