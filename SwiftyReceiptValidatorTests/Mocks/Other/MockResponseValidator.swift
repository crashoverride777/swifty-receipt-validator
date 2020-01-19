//
//  MockResponseValidator.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

final class MockResponseValidator {
    struct Stub {
        var validatePurchaseResult: (Result<SRVReceiptResponse, SRVError>) = .success(.mock())
        var validateSubscriptionResult: (Result<SRVSubscriptionValidationResponse, SRVError>) = .success(.mock())
    }
    
    struct Mock {
        var validatePurchase: (id: String, response: SRVReceiptResponse)? = nil
        var validateSubscription: (response: SRVReceiptResponse, now: Date)? = nil
    }
    
    var stub = Stub()
    private(set) var mock = Mock()
}

extension MockResponseValidator: ResponseValidatorType {
    
    func validatePurchase(forProductId productId: String,
                          in response: SRVReceiptResponse,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        mock.validatePurchase = (id: productId, response: response)
        handler(stub.validatePurchaseResult)
    }
    
    func validateSubscriptions(in response: SRVReceiptResponse,
                               now: Date,
                               handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void) {
        mock.validateSubscription = (response: response, now: now)
        handler(stub.validateSubscriptionResult)
    }
}
