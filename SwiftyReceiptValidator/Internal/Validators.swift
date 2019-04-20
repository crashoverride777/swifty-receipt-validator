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
            handler(.failure(.invalidStatusCode(response.status)))
            return
        }
        
        // Unwrap receipt
        guard let receipt = response.receipt else {
            handler(.failure(.noReceiptFoundInResponse(response.status)))
            return
        }
        
        // Check receipt contains correct bundle id
        guard receipt.bundleId == Bundle.main.bundleIdentifier else {
            handler(.failure(.bundleIdNotMatching(response.status)))
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
        guard let receipt = response.receipt?.inApp.first(where: { $0.productId == productId }) else {
            handler(.failure(.productIdNotMatching(response.status)))
            return
        }
        
        /*
         To check whether a purchase has been canceled by Apple Customer Support, look for the
         Cancellation Date field in the receipt. If the field contains a date, regardless
         of the subscription’s expiration date, the purchase has been canceled. With respect to
         providing content or service, treat a canceled transaction the same as if no purchase
         had ever been made.
         */
        guard receipt.cancellationDate == nil else {
            handler(.failure(.cancelled(response.status)))
            return
        }
        
        // Return success handler
        handler(.success(response))
    }
}

// MARK: - ReceiptSubscriptionValidator

extension ReceiptValidatorImplementation: ReceiptSubscriptionValidator {
    
    func validateSubscription(in response: SwiftyReceiptResponse,
                              handler: @escaping (Result<SwiftyReceiptResponse, SwiftyReceiptValidatorError>) -> Void) {
        // Make sure response subscription status is not expired
        guard response.status != .subscriptionExpired else {
            handler(.failure(.noValidSubscription(response.status)))
            return
        }
    
        // Make sure receipts are not empty
        guard !response.validSubscriptionReceipts.isEmpty else {
            handler(.failure(.noValidSubscription(response.status)))
            return
        }
        
        // Return success handler
        handler(.success((response)))
    }
}
