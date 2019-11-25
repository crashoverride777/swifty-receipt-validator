//
//  SwiftyReceiptValidatorType.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 25/11/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
import Combine

public protocol SwiftyReceiptValidatorType {
    // MARK: Purchases
    
    @available(iOS 13, *)
    func validatePurchasePublisher(forId productId: String, sharedSecret: String?) -> AnyPublisher<SRVReceiptResponse, SRVError>
    func validatePurchase(forId productId: String,
                          sharedSecret: String?,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
   
    // MARK: Subscriptions
    
    @available(iOS 13, *)
    func validateSubscriptionPublisher(sharedSecret: String?,
                                       refreshLocalReceiptIfNeeded: Bool,
                                       excludeOldTransactions: Bool) -> AnyPublisher<SRVSubscriptionValidationResponse, SRVError>
    func validateSubscription(sharedSecret: String?,
                              refreshLocalReceiptIfNeeded: Bool,
                              excludeOldTransactions: Bool,
                              handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void)
    
    // MARK: Fetch Only
    
    @available(iOS 13, *)
    func fetchPublisher(sharedSecret: String?,
                        refreshLocalReceiptIfNeeded: Bool,
                        excludeOldTransactions: Bool) -> AnyPublisher<SRVReceiptResponse, SRVError>
    func fetch(sharedSecret: String?,
               refreshLocalReceiptIfNeeded: Bool,
               excludeOldTransactions: Bool,
               handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
}
