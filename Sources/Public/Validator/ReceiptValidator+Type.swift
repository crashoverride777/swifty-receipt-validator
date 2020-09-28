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
    func validatePublisher(for request: SRVPurchaseValidationRequest) -> AnyPublisher<SRVReceiptResponse, SRVError>
    func validate(_ request: SRVPurchaseValidationRequest, handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
   
    @available(iOS 13, *)
    func validatePublisher(for request: SRVSubscriptionValidationRequest) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError>
    func validate(_ request: SRVSubscriptionValidationRequest, handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void)
}

extension SwiftyReceiptValidator: SwiftyReceiptValidatorType {
    
    // MARK: Purchase
    
    /// Validate app store purchase publisher
    ///
    /// - parameter request: The request configuration.
    @available(iOS 13, *)
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
    @available(iOS 13, *)
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
