//
//  PurchaseValidationRequestTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 19/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class PurchaseValidationRequestTests: XCTestCase {

    func test_init() {
        let productId = "123"
        let sharedSecret = "secret"
       
        let sut = SRVPurchaseValidationRequest(
            productId: productId,
            sharedSecret: sharedSecret
        )
        
        XCTAssertEqual(sut.productId, productId)
        XCTAssertEqual(sut.sharedSecret, sharedSecret)
    }
}
