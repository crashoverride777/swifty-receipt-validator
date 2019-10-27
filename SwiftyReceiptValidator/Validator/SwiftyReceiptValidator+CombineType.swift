//
//  SwiftyReceiptValidator+CombineType.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 11/10/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Combine

@available(iOS 13, *)
public protocol SwiftyReceiptValidatorCombineType {
    func validatePurchase(withId productId: String, sharedSecret: String?) -> AnyPublisher<SRVReceiptResponse, SRVError>
    func validateSubscription(sharedSecret: String?,
                              refreshLocalReceiptIfNeeded: Bool,
                              excludeOldTransactions: Bool) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError>
    func fetch(sharedSecret: String?,
               refreshLocalReceiptIfNeeded: Bool,
               excludeOldTransactions: Bool) -> AnyPublisher<SRVReceiptResponse, Error>
}

@available(iOS 13, *)
extension SwiftyReceiptValidator: SwiftyReceiptValidatorCombineType {
    
    // MARK: Validate Purchase
     
    /// Validate app store purchase publisher
    ///
    /// - parameter productId: The id of the purchase to verify.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func validatePurchase(withId productId: String,
                                  sharedSecret: String?) -> AnyPublisher<SRVReceiptResponse, SRVError> {
        return Future { [weak self] promise in
            self?.validatePurchase(withId: productId, sharedSecret: sharedSecret) { result in
                switch result {
                case .success(let response):
                    promise(.success(response))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: Validate Subscription
    
    /// Validate app store subscription publisher
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    public func validateSubscription(
        sharedSecret: String?,
        refreshLocalReceiptIfNeeded: Bool,
        excludeOldTransactions: Bool) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError> {
         return Future { [weak self] promise in
             self?.validateSubscription(
                 sharedSecret: sharedSecret,
                 refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
                 excludeOldTransactions: excludeOldTransactions,
                 handler: ({ result in
                     switch result {
                     case .success(let response):
                         promise(.success(response))
                     case .failure(let error):
                         promise(.failure(error))
                     }
                 })
             )
         }.eraseToAnyPublisher()
     }
    
    // MARK: Fetch Receipt Only
     
    /// Fetch receipt without any validation publisher
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    public func fetch(sharedSecret: String?,
                      refreshLocalReceiptIfNeeded: Bool,
                      excludeOldTransactions: Bool) -> AnyPublisher<SRVReceiptResponse, Error> {
        return Future { [weak self] promise in
            self?.fetch(
                sharedSecret: sharedSecret,
                refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
                excludeOldTransactions: excludeOldTransactions,
                handler: ({ result in
                    switch result {
                    case .success(let nestedResponse):
                        promise(.success(nestedResponse))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                })
            )
        }.eraseToAnyPublisher()
    }
}
