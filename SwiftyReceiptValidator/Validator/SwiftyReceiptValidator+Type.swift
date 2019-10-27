//
//  SwiftyReceiptValidator+Type.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 11/10/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public protocol SwiftyReceiptValidatorType {
    func validatePurchase(withId productId: String,
                          sharedSecret: String?,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
    func validateSubscription(sharedSecret: String?,
                              refreshLocalReceiptIfNeeded: Bool,
                              excludeOldTransactions: Bool,
                              handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void)
    func fetch(sharedSecret: String?,
               refreshLocalReceiptIfNeeded: Bool,
               excludeOldTransactions: Bool,
               handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
}

extension SwiftyReceiptValidator: SwiftyReceiptValidatorType {
    
    // MARK: Validate Purchase
   
    /// Validate app store purchase
    ///
    /// - parameter productId: The id of the purchase to verify.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter handler: Completion handler called when the validation has completed.
    public func validatePurchase(withId productId: String,
                                 sharedSecret: String?,
                                 handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        urlSessionRequest(
            sharedSecret: nil,
            refreshLocalReceiptIfNeeded: true,
            excludeOldTransactions: false,
            handler: ({ [weak self] result in
                switch result {
                case .success(let response):
                    self?.validator.validatePurchase(forProductId: productId, in: response, handler: handler)
                case .failure(let error):
                    handler(.failure(error))
                }
            })
        )
    }
    
    // MARK: Validate Subscription
    
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
        urlSessionRequest(sharedSecret: sharedSecret,
                          refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
                          excludeOldTransactions: excludeOldTransactions) { [weak self] result in
            switch result {
            case .success(let response):
                self?.validator.validateSubscription(in: response) { result in
                    switch result {
                    case .success(let nestedResponse):
                        let responseModel = SRVSubscriptionValidationResponse(
                            validReceipts: nestedResponse.validSubscriptionReceipts,
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
        }
    }

    // MARK: Fetch Receipt Only
    
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
        urlSessionRequest(sharedSecret: sharedSecret,
                          refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
                          excludeOldTransactions: excludeOldTransactions,
                          handler: handler)
    }
}
