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
        var validateSubscriptionResult: (Result<SRVReceiptResponse, SRVError>) = .success(.mock())
    }
    
    struct Mock {
        var validatePurchase: (id: String, response: SRVReceiptResponse)? = nil
        var validateSubscription: SRVReceiptResponse? = nil
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
    
    func validateSubscription(in response: SRVReceiptResponse,
                              handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        mock.validateSubscription = response
        handler(stub.validateSubscriptionResult)
    }
}
