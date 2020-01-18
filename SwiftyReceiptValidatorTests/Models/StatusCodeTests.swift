//
//  StatusCodeTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class StatusCodeTests: XCTestCase {
        
    func test_rawValue_unknown() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.unknown.rawValue, -1)
    }
    
    func test_rawValue_valid() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.valid.rawValue, 0)
    }
    
    func test_rawValue_jsonNotReadable() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.jsonNotReadable.rawValue, 21000)
    }
    
    func test_rawValue_malformedOrMissingData() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.malformedOrMissingData.rawValue, 21002)
    }
    
    func test_rawValue_receiptCouldNotBeAuthenticated() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.receiptCouldNotBeAuthenticated.rawValue, 21003)
    }
    
    func test_rawValue_sharedSecretNotMatching() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.sharedSecretNotMatching.rawValue, 21004)
    }
    
    func test_rawValue_receiptServerUnavailable() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.receiptServerUnavailable.rawValue, 21005)
    }
    
    func test_rawValue_subscriptionExpired() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.subscriptionExpired.rawValue, 21006)
    }
    
    func test_rawValue_testReceipt() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.testReceipt.rawValue, 21007)
    }
    
    func test_rawValue_productionEnvironment() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.productionEnvironment.rawValue, 21008)
    }
    
    func test_rawValue_receiptCouldNotBeAuthorized() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.receiptCouldNotBeAuthorized.rawValue, 21010)
    }
}
