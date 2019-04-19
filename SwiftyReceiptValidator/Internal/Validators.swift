//
//  Validators.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

final class ReceiptValidatorImplementation {
    
}

// MARK: - ReceiptDefaultValidator

extension ReceiptValidatorImplementation: ReceiptDefaultValidator {
   
    func validate(_ response: SwiftyReceiptResponse,
                  handler: @escaping SwiftyReceiptValidatorResultHandler) {
        // Check receipt status code is valid
        guard response.status == .valid else {
            handler(.failure(.invalidStatusCode, code: response.status))
            return
        }
        
        // Unwrap receipt
        guard let receipt = response.receipt else {
            handler(.failure(.noReceiptFoundInResponse, code: response.status))
            return
        }
        
        // Check receipt contains correct bundle id
        guard receipt.bundleId == Bundle.main.bundleIdentifier else {
            handler(.failure(.bundleIdNotMatching, code: response.status))
            return
        }
        
        // Return success
        handler(.success(response))
    }
}

// MARK: - ReceiptPurchaseValidator

extension ReceiptValidatorImplementation: ReceiptPurchaseValidator {
    
    func validatePurchase(forProductId productId: String,
                          in response: SwiftyReceiptResponse,
                          handler: @escaping SwiftyReceiptValidatorResultHandler) {
        // Check a valid receipt with matching product id was found
        guard response.receipt?.inApp.first(where: { $0.productId == productId }) != nil else {
            handler(.failure(.productIdNotMatching, code: response.status))
            return
        }
        
        // Return success handler
        handler(.success(response))
    }
}

// MARK: - ReceiptSubscriptionValidator

extension ReceiptValidatorImplementation: ReceiptSubscriptionValidator {
    
    func validateSubscription(in response: SwiftyReceiptResponse,
                              handler: @escaping (SwiftyReceiptValidatorResult<(SwiftyReceiptResponse)>) -> Void) {
        // Make sure response subscription status is not expired
        guard response.status != .subscriptionExpired else {
            handler(.failure(.noValidSubscription, code: response.status))
            return
        }
    
        // Make sure receipts are not empty
        guard !response.validSubscriptionReceipts.isEmpty else {
            handler(.failure(.noValidSubscription, code: response.status))
            return
        }
        
        // Return success handler
        handler(.success((response)))
    }
}
