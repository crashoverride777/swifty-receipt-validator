//
//  Validators.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2016-2019 Dominik Ringler
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

final class ReceiptValidatorImplementation {
    typealias ResultHandler = (Result<SwiftyReceiptResponse, SwiftyReceiptValidatorError>) -> Void
}

// MARK: - SwiftyReceiptDefaultValidator

extension ReceiptValidatorImplementation: SwiftyReceiptDefaultValidator {
   
    func validate(_ response: SwiftyReceiptResponse, handler: @escaping ResultHandler) {
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

// MARK: - SwiftyReceiptPurchaseValidator

extension ReceiptValidatorImplementation: SwiftyReceiptPurchaseValidator {
    
    func validatePurchase(forProductId productId: String,
                          in response: SwiftyReceiptResponse,
                          handler: @escaping ResultHandler) {
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

// MARK: - SwiftyReceiptSubscriptionValidator

extension ReceiptValidatorImplementation: SwiftyReceiptSubscriptionValidator {
    
    func validateSubscription(in response: SwiftyReceiptResponse, handler: @escaping ResultHandler) {
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
