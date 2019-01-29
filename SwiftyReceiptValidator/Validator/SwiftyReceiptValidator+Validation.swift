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
                guard let expiresDate = $0.expiresDate else { return true }
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
