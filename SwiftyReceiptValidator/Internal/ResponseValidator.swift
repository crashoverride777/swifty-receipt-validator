//
//  ResponseValidator.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

protocol ResponseValidatorType: AnyObject {
    func validatePurchase(forProductId productId: String,
                          in response: SRVReceiptResponse,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
    func validateSubscription(in response: SRVReceiptResponse,
                              handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
}

final class ResponseValidator {
    private let bundle: Bundle
    
    init(bundle: Bundle) {
        self.bundle = bundle
    }
}

// MARK: - ResponseValidatorType

extension ResponseValidator: ResponseValidatorType {
  
    func validatePurchase(forProductId productId: String,
                          in response: SRVReceiptResponse,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        runBasicValidation(for: response) { result in
            switch result {
            case .success:
                guard let receiptInApp = response.receipt?.inApp.first(where: { $0.productId == productId }) else {
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
                guard receiptInApp.cancellationDate == nil else {
                    handler(.failure(.cancelled(response.status)))
                    return
                }
                
                handler(.success(response))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func validateSubscription(in response: SRVReceiptResponse, handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        runBasicValidation(for: response) { result in
            switch result {
            case .success:
                guard response.status != .subscriptionExpired else {
                    handler(.failure(.noValidSubscription(response.status)))
                    return
                }
                        
                guard !response.validSubscriptionReceipts(now: Date()).isEmpty else {
                    handler(.failure(.noValidSubscription(response.status)))
                    return
                }
                
                handler(.success((response)))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

// MARK: - Private Methods

private extension ResponseValidator {
    
    func runBasicValidation(for response: SRVReceiptResponse, handler: (Result<Void, SRVError>) -> ()) {
        // Check receipt status code is valid
        guard response.status.isValid else {
            handler(.failure(.invalidStatusCode(response.status)))
            return
        }
       
        // Unwrap receipt
        guard let receipt = response.receipt else {
            handler(.failure(.noReceiptFoundInResponse(response.status)))
            return
        }
       
        // Check receipt contains correct bundle id
        guard receipt.bundleId == bundle.bundleIdentifier else {
            handler(.failure(.bundleIdNotMatching(response.status)))
            return
        }
        
        handler(.success(()))
    }
}
