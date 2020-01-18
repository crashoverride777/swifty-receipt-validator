//
//  ReceiptValidator+Type.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 11/10/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
import Combine

public protocol SwiftyReceiptValidatorType {
    @available(iOS 13, *)
    func validatePurchasePublisher(forId productId: String, sharedSecret: String?) -> AnyPublisher<SRVReceiptResponse, SRVError>
    func validatePurchase(forId productId: String,
                          sharedSecret: String?,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
   
    @available(iOS 13, *)
    func validateSubscriptionPublisher(sharedSecret: String?,
                                       refreshLocalReceiptIfNeeded: Bool,
                                       excludeOldTransactions: Bool) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError>
    func validateSubscription(sharedSecret: String?,
                              refreshLocalReceiptIfNeeded: Bool,
                              excludeOldTransactions: Bool,
                              handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void)
    
    @available(iOS 13, *)
    func fetchPublisher(sharedSecret: String?,
                        refreshLocalReceiptIfNeeded: Bool,
                        excludeOldTransactions: Bool) -> AnyPublisher<SRVReceiptResponse, SRVError>
    func fetch(sharedSecret: String?,
               refreshLocalReceiptIfNeeded: Bool,
               excludeOldTransactions: Bool,
               handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
}

extension SwiftyReceiptValidator: SwiftyReceiptValidatorType {
    
    // MARK: Purchase
    
    /// Validate app store purchase publisher
    ///
    /// - parameter productId: The id of the purchase to verify.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter handler: Completion handler called when the validation has completed.
    @available(iOS 13, *)
    public func validatePurchasePublisher(forId productId: String,
                                          sharedSecret: String?) -> AnyPublisher<SRVReceiptResponse, SRVError> {
        return Future { [weak self] promise in
            self?.validatePurchase(forId: productId, sharedSecret: sharedSecret, handler: promise)
        }.eraseToAnyPublisher()
    }
   
    /// Validate app store purchase
    ///
    /// - parameter productId: The id of the purchase to verify.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func validatePurchase(forId productId: String,
                                 sharedSecret: String?,
                                 handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        urlSessionRequest(
            sharedSecret: sharedSecret,
            refreshLocalReceiptIfNeeded: true,
            excludeOldTransactions: false,
            handler: ({ [weak self] result in
                switch result {
                case .success(let response):
                    self?.responseValidator.validatePurchase(forProductId: productId, in: response, handler: handler)
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
        sharedSecret: String?,
        refreshLocalReceiptIfNeeded: Bool,
        excludeOldTransactions: Bool) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError> {
         return Future { [weak self] promise in
             self?.validateSubscription(
                 sharedSecret: sharedSecret,
                 refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
                 excludeOldTransactions: excludeOldTransactions,
                 handler: promise
             )
         }.eraseToAnyPublisher()
     }
    
    /// Validate app store subscription
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func validateSubscription(
        sharedSecret: String?,
        refreshLocalReceiptIfNeeded: Bool,
        excludeOldTransactions: Bool,
        handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void) {
        urlSessionRequest(
            sharedSecret: sharedSecret,
            refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
            excludeOldTransactions: excludeOldTransactions,
            handler: ({ [weak self] result in
                switch result {
                case .success(let response):
                    self?.responseValidator.validateSubscription(in: response) { result in
                        switch result {
                        case .success(let nestedResponse):
                            let responseModel = SRVSubscriptionValidationResponse(
                                validReceipts: nestedResponse.validSubscriptionReceipts(now: Date()),
                                pendingRenewalInfo: nestedResponse.pendingRenewalInfo
                            )
                            handler(.success(responseModel))
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            })
        )
    }

    // MARK: Fetch Only
    
    /// Fetch receipt without any validation publisher
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    @available(iOS 13, *)
    public func fetchPublisher(sharedSecret: String?,
                               refreshLocalReceiptIfNeeded: Bool,
                               excludeOldTransactions: Bool) -> AnyPublisher<SRVReceiptResponse, SRVError> {
        return Future { [weak self] promise in
            self?.fetch(
                sharedSecret: sharedSecret,
                refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
                excludeOldTransactions: excludeOldTransactions,
                handler: promise
            )
        }.eraseToAnyPublisher()
    }
    
    /// Fetch receipt without any validation
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func fetch(sharedSecret: String?,
                      refreshLocalReceiptIfNeeded: Bool,
                      excludeOldTransactions: Bool,
                      handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        urlSessionRequest(
            sharedSecret: sharedSecret,
            refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
            excludeOldTransactions: excludeOldTransactions,
            handler: handler
        )
    }
}
