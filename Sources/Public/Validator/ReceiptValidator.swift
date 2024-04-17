//    The MIT License (MIT)
//
//    Copyright (c) 2016-2024 Dominik Ringler
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

import Foundation
import Combine
import StoreKit

public protocol SwiftyReceiptValidatorType {
    func validate(_ request: SRVPurchaseValidationRequest, completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void)
    func validate(_ request: SRVPurchaseValidationRequest) async throws -> SRVReceiptResponse
    func validatePublisher(for request: SRVPurchaseValidationRequest) -> AnyPublisher<SRVReceiptResponse, Error>
    
    func validate(_ request: SRVSubscriptionValidationRequest, completion: @escaping (Result<SRVSubscriptionValidationResponse, Error>) -> Void)
    func validate(_ request: SRVSubscriptionValidationRequest) async throws -> SRVSubscriptionValidationResponse
    func validatePublisher(for request: SRVSubscriptionValidationRequest) -> AnyPublisher<SRVSubscriptionValidationResponse, Error>
}

/*
 SwiftyReceiptValidator
 
 A concrete implementation of SwiftyReceiptValidatorType to manage in app purchase receipt validation
 */
public final class SwiftyReceiptValidator {
    
    // MARK: - Properties
    
    private let configuration: SRVConfiguration
    private let receiptURLFetcher: ReceiptURLFetcher
    private let receiptClient: ReceiptClient
    private let responseValidator: ResponseValidator
    
    // MARK: - Initialization
    
    /// Initializer
    ///
    /// - parameter configuration: The configuration needed for SwiftyReceiptValidator.
    /// - parameter isLoggingEnabled: Displays console logging events if set to true.
    public init(configuration: SRVConfiguration, isLoggingEnabled: Bool) {
        self.configuration = configuration
        
        receiptURLFetcher = DefaultReceiptURLFetcher(
            appStoreReceiptURL: { Bundle.main.appStoreReceiptURL },
            fileManager: .default
        )
        
        receiptClient = DefaultReceiptClient(
            sessionManager: DefaultURLSessionManager(
                sessionConfiguration: configuration.sessionConfiguration,
                encoder: JSONEncoder()
            ),
            productionURL: configuration.productionURL,
            sandboxURL: configuration.sandboxURL,
            isLoggingEnabled: isLoggingEnabled
        )
        
        responseValidator = DefaultResponseValidator(
            bundle: .main,
            isLoggingEnabled: isLoggingEnabled
        )
    }
    
    // Internal only used for testing
    init(configuration: SRVConfiguration,
         receiptURLFetcher: ReceiptURLFetcher,
         receiptClient: ReceiptClient,
         responseValidator: ResponseValidator) {
        self.configuration = configuration
        self.receiptURLFetcher = receiptURLFetcher
        self.receiptClient = receiptClient
        self.responseValidator = responseValidator
    }
}

// MARK: - SwiftyReceiptValidatorType

extension SwiftyReceiptValidator: SwiftyReceiptValidatorType {
    
    // MARK: Purchase
    
    /// Validate app store purchase.
    ///
    /// - parameter request: The validation request configuration.
    /// - parameter completion: Completion handler called when the validation has completed.
    public func validate(_ request: SRVPurchaseValidationRequest, completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
        fetchReceipt(
            sharedSecret: request.sharedSecret,
            refreshLocalReceiptIfNeeded: true,
            excludeOldTransactions: false,
            completion: ({ [weak self] result in
                switch result {
                case .success(let response):
                    self?.responseValidator.validatePurchase(
                        in: response,
                        productId: request.productIdentifier,
                        completion: completion
                    )
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        )
    }
    
    /// Validate app store purchase.
    ///
    /// - parameter request: The validation request configuration.
    /// - returns: The SRVReceiptResponse if no error is thrown.
    public func validate(_ request: SRVPurchaseValidationRequest) async throws -> SRVReceiptResponse {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.validate(request) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Validate app store purchase publisher.
    ///
    /// - parameter request: The validation request configuration.
    public func validatePublisher(for request: SRVPurchaseValidationRequest) -> AnyPublisher<SRVReceiptResponse, Error> {
        Deferred {
            Future { [weak self] promise in
                self?.validate(request, completion: promise)
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: Subscription
    
    /// Validate app store subscription.
    ///
    /// - parameter request: The request configuration.
    /// - parameter completion: Completion handler called when the validation has completed.
    public func validate(_ request: SRVSubscriptionValidationRequest, completion: @escaping (Result<SRVSubscriptionValidationResponse, Error>) -> Void) {
        fetchReceipt(
            sharedSecret: request.sharedSecret,
            refreshLocalReceiptIfNeeded: request.refreshLocalReceiptIfNeeded,
            excludeOldTransactions: request.excludeOldTransactions,
            completion: ({ [weak self] result in
                switch result {
                case .success(let response):
                    self?.responseValidator.validateSubscriptions(
                        in: response,
                        now: request.now,
                        completion: completion
                    )
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        )
    }
    
    /// Validate app store subscription.
    ///
    /// - parameter request: The validation request configuration.
    /// - returns: The SRVSubscriptionValidationResponse if no error thrown.
    public func validate(_ request: SRVSubscriptionValidationRequest) async throws -> SRVSubscriptionValidationResponse {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.validate(request) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Validate app store subscription publisher.
    ///
    /// - parameter request: The request configuration.
    public func validatePublisher(for request: SRVSubscriptionValidationRequest) -> AnyPublisher<SRVSubscriptionValidationResponse, Error> {
        Deferred {
            Future { [weak self] promise in
                self?.validate(request, completion: promise)
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Private Methods

private extension SwiftyReceiptValidator {
    func fetchReceipt(sharedSecret: String?,
                      refreshLocalReceiptIfNeeded: Bool,
                      excludeOldTransactions: Bool,
                      completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
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
                self.receiptClient.perform(clientRequest, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
