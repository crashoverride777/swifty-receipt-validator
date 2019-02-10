//
//  SwiftyReceiptValidator+Internal.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

extension SwiftyReceiptValidator {
    
    func validate(_ response: SwiftyReceiptResponse, validationMode: ValidationMode, handler: @escaping ResultHandler) {
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
        
        // Run the validation for the correct mode
        switch validationMode {
            
        case .none:
            break
            
        case .purchase(let productId):
            // Check a valid receipt with matching product id was found
            guard receipt.inApp.first(where: { $0.productId == productId }) != nil else {
                handler(.failure(.productIdNotMatching, code: response.status))
                return
            }
            
        case .subscription:
            var receipts = response.latestReceiptInfo ?? receipt.inApp
            receipts.removeAll {			
				/*
				From the In-App Purchase Programming Guide:
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
        }
        
        // Return success handler
        handler(.success(response))
    }
}

