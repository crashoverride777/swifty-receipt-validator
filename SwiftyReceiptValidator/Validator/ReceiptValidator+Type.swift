//
//  ReceiptValidator+Type.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 11/10/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
import StoreKit
import Combine

public protocol SwiftyReceiptValidatorType {
    @available(iOS 13, *)
    func validatePurchasePublisher(
        for request: SwiftyReceiptValidatorPurchaseRequest
    ) -> AnyPublisher<SRVReceiptResponse, SRVError>
    func validatePurchase(
        for request: SwiftyReceiptValidatorPurchaseRequest,
        handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void
    )
   
    @available(iOS 13, *)
    func validateSubscriptionPublisher(
        for request: SwiftyReceiptValidatorSubscriptionRequest
    ) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError>
    func validateSubscription(
        for request: SwiftyReceiptValidatorSubscriptionRequest,
        handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void
    )
}

extension SwiftyReceiptValidator: SwiftyReceiptValidatorType {
    
    // MARK: Purchase
    
    /// Validate app store purchase publisher
    ///
    /// - parameter productId: The id of the purchase to verify.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter handler: Completion handler called when the validation has completed.
    @available(iOS 13, *)
    public func validatePurchasePublisher(
        for request: SwiftyReceiptValidatorPurchaseRequest
    ) -> AnyPublisher<SRVReceiptResponse, SRVError> {
        return Future { [weak self] promise in
            self?.validatePurchase(for: request, handler: promise)
        }.eraseToAnyPublisher()
    }
   
    /// Validate app store purchase
    ///
    /// - parameter productId: The id of the purchase to verify.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func validatePurchase(
        for request: SwiftyReceiptValidatorPurchaseRequest,
        handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void
    ) {
        fetchReceipt(
            sharedSecret: request.sharedSecret,
            refreshLocalReceiptIfNeeded: true,
            excludeOldTransactions: false,
            handler: ({ [weak self] result in
                switch result {
                case .success(let response):
                    self?.responseValidator.validatePurchase(
                        forProductId: request.productId,
                        in: response,
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
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    @available(iOS 13, *)
    public func validateSubscriptionPublisher(
        for request: SwiftyReceiptValidatorSubscriptionRequest
    ) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError> {
         return Future { [weak self] promise in
             self?.validateSubscription(for: request, handler: promise)
         }.eraseToAnyPublisher()
     }
    
    /// Validate app store subscription
    ///
    /// - parameter request: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func validateSubscription(
        for request: SwiftyReceiptValidatorSubscriptionRequest,
        handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void
    ) {
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
                self.receiptClient.fetch(
                    with: receiptURL,
                    sharedSecret: sharedSecret,
                    excludeOldTransactions: excludeOldTransactions,
                    handler: handler
                )
            case .failure(let error):
                handler(.failure(.other(error)))
            }
        }
    }
}
