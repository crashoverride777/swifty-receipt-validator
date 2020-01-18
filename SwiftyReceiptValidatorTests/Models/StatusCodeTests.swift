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
        XCTAssertEqual(SRVStatusCode.unknown.rawValue, -1)
    }
    
    func test_rawValue_valid() {
        XCTAssertEqual(SRVStatusCode.valid.rawValue, 0)
    }
    
    func test_rawValue_jsonNotReadable() {
        XCTAssertEqual(SRVStatusCode.jsonNotReadable.rawValue, 21000)
    }
    
    func test_rawValue_malformedOrMissingData() {
        XCTAssertEqual(SRVStatusCode.malformedOrMissingData.rawValue, 21002)
    }
    
    func test_rawValue_receiptCouldNotBeAuthenticated() {
        XCTAssertEqual(SRVStatusCode.receiptCouldNotBeAuthenticated.rawValue, 21003)
    }
    
    func test_rawValue_sharedSecretNotMatching() {
        XCTAssertEqual(SRVStatusCode.sharedSecretNotMatching.rawValue, 21004)
    }
    
    func test_rawValue_receiptServerUnavailable() {
        XCTAssertEqual(SRVStatusCode.receiptServerUnavailable.rawValue, 21005)
    }
    
    func test_rawValue_subscriptionExpired() {
        XCTAssertEqual(SRVStatusCode.subscriptionExpired.rawValue, 21006)
    }
    
    func test_rawValue_testReceipt() {
        XCTAssertEqual(SRVStatusCode.testReceipt.rawValue, 21007)
    }
    
    func test_rawValue_productionEnvironment() {
        XCTAssertEqual(SRVStatusCode.productionEnvironment.rawValue, 21008)
    }
    
    func test_rawValue_receiptCouldNotBeAuthorized() {
        XCTAssertEqual(SRVStatusCode.receiptCouldNotBeAuthorized.rawValue, 21010)
    }
}
