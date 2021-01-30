//
//  ReceiptValidator.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2016-2021 Dominik Ringler
 
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

import Foundation
import Combine
import StoreKit

public protocol SwiftyReceiptValidatorType {
    @available(iOS 13, tvOS 13, macOS 10.15, *)
    func validatePublisher(for request: SRVPurchaseValidationRequest) -> AnyPublisher<SRVReceiptResponse, SRVError>
    func validate(_ request: SRVPurchaseValidationRequest, handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)

    @available(iOS 13, tvOS 13, macOS 10.15, *)
    func validatePublisher(for request: SRVSubscriptionValidationRequest) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError>
    func validate(_ request: SRVSubscriptionValidationRequest, handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void)
}

/*
 SwiftyReceiptValidator
 
 A concrete implementation of SwiftyReceiptValidatorType to manage in app purchase receipt validation
 */
public final class SwiftyReceiptValidator {
   
    // MARK: - Properties

    private let configuration: SRVConfiguration
    private let receiptURLFetcher: ReceiptURLFetcherType
    private let receiptClient: ReceiptClientType
    private let responseValidator: ResponseValidatorType
    
    // MARK: - Initialization
    
    /// Initializer
    ///
    /// - parameter configuration: The configuration needed for SwiftyReceiptValidator.
    /// - parameter isLoggingEnabled: Displays console logging events if set to true.
    public init(configuration: SRVConfiguration, isLoggingEnabled: Bool) {
        self.configuration = configuration

        receiptURLFetcher = ReceiptURLFetcher(
            appStoreReceiptURL: { Bundle.main.appStoreReceiptURL },
            fileManager: .default
        )

        receiptClient = ReceiptClient(
            sessionManager: URLSessionManager(
                sessionConfiguration: configuration.sessionConfiguration,
                encoder: JSONEncoder()
            ),
            productionURL: configuration.productionURL,
            sandboxURL: configuration.sandboxURL,
            isLoggingEnabled: isLoggingEnabled
        )

        responseValidator = ResponseValidator(
            bundle: .main,
            isLoggingEnabled: isLoggingEnabled
        )
    }
    
    // Internal only used for testing
    init(configuration: SRVConfiguration,
         receiptURLFetcher: ReceiptURLFetcherType,
         receiptClient: ReceiptClientType,
         responseValidator: ResponseValidatorType) {
        self.configuration = configuration
        self.receiptURLFetcher = receiptURLFetcher
        self.receiptClient = receiptClient
        self.responseValidator = responseValidator
    }
}

// MARK: - SwiftyReceiptValidatorType

extension SwiftyReceiptValidator: SwiftyReceiptValidatorType {

    // MARK: Purchase

    /// Validate app store purchase publisher
    ///
    /// - parameter request: The request configuration.
    @available(iOS 13, tvOS 13, macOS 10.15, *)
    public func validatePublisher(for request: SRVPurchaseValidationRequest) -> AnyPublisher<SRVReceiptResponse, SRVError> {
        Future { [weak self] promise in
            self?.validate(request, handler: promise)
        }.eraseToAnyPublisher()
    }

    /// Validate app store purchase
    ///
    /// - parameter request: The request configuration.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func validate(_ request: SRVPurchaseValidationRequest, handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        fetchReceipt(
            sharedSecret: request.sharedSecret,
            refreshLocalReceiptIfNeeded: true,
            excludeOldTransactions: false,
            handler: ({ [weak self] result in
                switch result {
                case .success(let response):
                    self?.responseValidator.validatePurchase(
                        in: response,
                        productId: request.productId,
                        handler: handler
                    )
                case .failure(let error):
                    handler(.failure(error))
                }
            })
        )
    }

    // MARK: Subscription

    /// Validate app store subscription publisher
    ///
    /// - parameter request: The request configuration.
    @available(iOS 13, tvOS 13, macOS 10.15, *)
    public func validatePublisher(for request: SRVSubscriptionValidationRequest) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError> {
        Future { [weak self] promise in
             self?.validate(request, handler: promise)
         }.eraseToAnyPublisher()
     }

    /// Validate app store subscription
    ///
    /// - parameter request: The request configuration.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func validate(_ request: SRVSubscriptionValidationRequest, handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void) {
        fetchReceipt(
            sharedSecret: request.sharedSecret,
            refreshLocalReceiptIfNeeded: request.refreshLocalReceiptIfNeeded,
            excludeOldTransactions: request.excludeOldTransactions,
            handler: ({ [weak self] result in
                switch result {
                case .success(let response):
                    self?.responseValidator.validateSubscriptions(
                        in: response,
                        now: request.now,
                        handler: handler
                    )
                case .failure(let error):
                    handler(.failure(error))
                }
            })
        )
    }
}

// MARK: - Private Methods

private extension SwiftyReceiptValidator {

    func fetchReceipt(sharedSecret: String?,
                      refreshLocalReceiptIfNeeded: Bool,
                      excludeOldTransactions: Bool,
                      handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        let refreshRequest = refreshLocalReceiptIfNeeded ? SKReceiptRefreshRequest(receiptProperties: nil) : nil
        receiptURLFetcher.fetch(refreshRequest: refreshRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let receiptURL):
                let clientRequest = ReceiptClientRequest(
                    receiptURL: receiptURL,
                    sharedSecret: sharedSecret,
                    excludeOldTransactions: excludeOldTransactions
                )
                self.receiptClient.perform(clientRequest, handler: handler)
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
