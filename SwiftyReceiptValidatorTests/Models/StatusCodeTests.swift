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
        
    // MARK: Raw Value
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
    
    // MARK: Is Valid
    
    func test_isValid_unknown_returnsFalse() {
        let sut: SRVStatusCode = .unknown
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_validStatusCode_returnsTrue() {
        let sut: SRVStatusCode = .valid
        XCTAssertTrue(sut.isValid)
    }
    
    func test_isValid_jsonNotReadable_returnsFalse() {
        let sut: SRVStatusCode = .jsonNotReadable
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_malformedOrMissingData_returnsFalse() {
        let sut: SRVStatusCode = .malformedOrMissingData
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_receiptCouldNotBeAuthenticated_returnsFalse() {
        let sut: SRVStatusCode = .receiptCouldNotBeAuthenticated
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_sharedSecretNotMatching_returnsFalse() {
        let sut: SRVStatusCode = .sharedSecretNotMatching
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_receiptServerUnavailable_returnsFalse() {
        let sut: SRVStatusCode = .receiptServerUnavailable
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_subscriptionExpired_returnsTrue() {
        let sut: SRVStatusCode = .subscriptionExpired
        XCTAssertTrue(sut.isValid)
    }
    
    func test_isValid_testReceipt_returnsFalse() {
        let sut: SRVStatusCode = .testReceipt
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_productionEnvironment_returnsFalse() {
        let sut: SRVStatusCode = .productionEnvironment
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_receiptCouldNotBeAuthorized_returnsFalse() {
        let sut: SRVStatusCode = .receiptCouldNotBeAuthorized
        XCTAssertFalse(sut.isValid)
    }
}
