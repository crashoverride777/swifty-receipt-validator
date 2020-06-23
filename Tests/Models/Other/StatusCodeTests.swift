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
    
    func test_rawValue() {
        XCTAssertEqual(SRVStatusCode.unknown.rawValue, -1)
        XCTAssertEqual(SRVStatusCode.valid.rawValue, 0)
        XCTAssertEqual(SRVStatusCode.jsonNotReadable.rawValue, 21000)
        XCTAssertEqual(SRVStatusCode.malformedOrMissingData.rawValue, 21002)
        XCTAssertEqual(SRVStatusCode.receiptCouldNotBeAuthenticated.rawValue, 21003)
        XCTAssertEqual(SRVStatusCode.sharedSecretNotMatching.rawValue, 21004)
        XCTAssertEqual(SRVStatusCode.receiptServerUnavailable.rawValue, 21005)
        XCTAssertEqual(SRVStatusCode.subscriptioniOS6StyleExpired.rawValue, 21006)
        XCTAssertEqual(SRVStatusCode.testReceipt.rawValue, 21007)
        XCTAssertEqual(SRVStatusCode.productionEnvironment.rawValue, 21008)
        XCTAssertEqual(SRVStatusCode.receiptCouldNotBeAuthorized.rawValue, 21010)
        XCTAssertEqual(SRVStatusCode.internalDataAccessError.rawValue, 21100)
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
        let sut: SRVStatusCode = .subscriptioniOS6StyleExpired
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
    
    func test_isValid_internalDataAccessError_returnsFalse() {
        let sut: SRVStatusCode = .internalDataAccessError
        XCTAssertFalse(sut.isValid)
    }
}
