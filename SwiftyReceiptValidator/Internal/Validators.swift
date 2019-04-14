//
//  Validators.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

typealias SwiftyReceiptValidators = ReceiptDefaultValidator & ReceiptPurchaseValidator & ReceiptSubscriptionValidator

protocol ReceiptDefaultValidator {
    func validate(_ response: SwiftyReceiptResponse, handler: @escaping SwiftyReceiptValidatorResultHandler)
}

protocol ReceiptPurchaseValidator {
    func validatePurchase(forProductId productId: String,
                          in response: SwiftyReceiptResponse,
                          handler: @escaping SwiftyReceiptValidatorResultHandler)
}

protocol ReceiptSubscriptionValidator {
    func validateSubscription(in response: SwiftyReceiptResponse, handler: @escaping SwiftyReceiptValidatorResultHandler)
}

/// Implementation
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
    
    func validateSubscription(in response: SwiftyReceiptResponse, handler: @escaping SwiftyReceiptValidatorResultHandler) {
        var receipts = response.latestReceiptInfo ?? response.receipt?.inApp ?? []
        
        receipts.removeAll {
            /*
             To check whether a purchase has been canceled by Apple Customer Support, look for the
             Cancellation Date field in the receipt. If the field contains a date, regardless
             of the subscription’s expiration date, the purchase has been canceled. With respect to
             providing content or service, treat a canceled transaction the same as if no purchase
             had ever been made.
             */
            guard let expiresDate = $0.expiresDate, $0.cancellationDate == nil else { return true }
            return expiresDate < Date()
        }
        
        guard response.status != .subscriptionExpired, !receipts.isEmpty else {
            handler(.failure(.noValidSubscription, code: response.status))
            return
        }
        
        // Return success handler
        handler(.success(response))
    }
}
