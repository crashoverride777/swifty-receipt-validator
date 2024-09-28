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
import StoreKit
@preconcurrency import Combine

public protocol SwiftyReceiptValidator: Sendable {
    func validate(_ request: SRVPurchaseValidationRequest) async throws -> SRVReceiptResponse
    func validate(_ request: SRVPurchaseValidationRequest,
                  completion: @escaping @Sendable (Result<SRVReceiptResponse, Error>) -> Void)
    
    func validate(_ request: SRVSubscriptionValidationRequest) async throws -> SRVSubscriptionValidationResponse
    func validate(_ request: SRVSubscriptionValidationRequest,
                  completion: @escaping @Sendable (Result<SRVSubscriptionValidationResponse, Error>) -> Void)
}

/*
 DefaultSwiftyReceiptValidator
 
 A concrete implementation of `SwiftyReceiptValidator` to manage in app purchase receipt validation.
 */
public final class DefaultSwiftyReceiptValidator {
    
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
    
    // Testing only
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

// MARK: - SwiftyReceiptValidator

extension DefaultSwiftyReceiptValidator: SwiftyReceiptValidator {
    /// Validate app store purchase.
    ///
    /// - parameter request: The validation request configuration.
    /// - returns: The SRVReceiptResponse if no error is thrown.
    public func validate(_ request: SRVPurchaseValidationRequest) async throws -> SRVReceiptResponse {
        let receiptResponse = try await fetchReceipt(
            sharedSecret: request.sharedSecret,
            refreshLocalReceiptIfNeeded: true,
            excludeOldTransactions: false
        )
        return try await responseValidator.validatePurchase(for: receiptResponse, productID: request.productIdentifier)
    }
    
    /// - parameter request: The validation request configuration.
    /// - parameter completion: A completion block with the validated SRVReceiptResponse or error.
    public func validate(_ request: SRVPurchaseValidationRequest,
                         completion: @escaping @Sendable (Result<SRVReceiptResponse, Error>) -> Void) {
        Task {
            do {
                let response = try await validate(request)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Validate app store subscription.
    ///
    /// - parameter request: The validation request configuration.
    /// - returns: The SRVSubscriptionValidationResponse.
    public func validate(_ request: SRVSubscriptionValidationRequest) async throws -> SRVSubscriptionValidationResponse {
        let receiptResponse = try await fetchReceipt(
            sharedSecret: request.sharedSecret,
            refreshLocalReceiptIfNeeded: request.refreshLocalReceiptIfNeeded,
            excludeOldTransactions: request.excludeOldTransactions
        )
        return try await responseValidator.validateSubscriptions(for: receiptResponse, now: request.now)
    }
    
    /// - parameter request: The validation request configuration.
    /// - parameter completion: A completion block with the validated SRVSubscriptionValidationResponse or error.
    public func validate(_ request: SRVSubscriptionValidationRequest,
                         completion: @escaping @Sendable (Result<SRVSubscriptionValidationResponse, Error>) -> Void) {
        Task {
            do {
                let response = try await validate(request)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private Methods

private extension DefaultSwiftyReceiptValidator {
    func fetchReceipt(sharedSecret: String?, refreshLocalReceiptIfNeeded: Bool, excludeOldTransactions: Bool) async throws -> SRVReceiptResponse {
        let refreshRequest = refreshLocalReceiptIfNeeded ? SKReceiptRefreshRequest(receiptProperties: nil) : nil
        let receiptURL = try await fetchReceiptURL(with: refreshRequest)
        let receiptClientRequest = ReceiptClientRequest(
            receiptURL: receiptURL,
            sharedSecret: sharedSecret,
            excludeOldTransactions: excludeOldTransactions
        )
        return try await receiptClient.perform(receiptClientRequest)
    }
    
    func fetchReceiptURL(with refreshRequest: SKReceiptRefreshRequest?) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            receiptURLFetcher.fetch(refreshRequest: refreshRequest) { result in
                continuation.resume(with: result)
            }
        }
    }
}
