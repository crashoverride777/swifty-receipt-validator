//
//  SwiftyReceiptResponseTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class SwiftyReceiptResponseTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: SwiftyReceiptResponse!
    
    // MARK: - Life Cycle
    
    override func setUp() {
        super.setUp()
        sut = .fake()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    #warning("add tests/finish")
    // MARK: - Tests
    
    // MARK: Valid Subscription Receipts
    
    func test_receiptResponse_validSubscriptionReceipts() {
        //sut.validSubscriptionReceipts
    }
    
    // MARK: Status Code
    
    func test_receiptResponse_statusCodes() {
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.unknown.rawValue, -1)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.valid.rawValue, 0)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.jsonNotReadable.rawValue, 21000)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.malformedOrMissingData.rawValue, 21002)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.receiptCouldNotBeAuthenticated.rawValue, 21003)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.sharedSecretNotMatching.rawValue, 21004)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.receiptServerUnavailable.rawValue, 21005)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.subscriptionExpired.rawValue, 21006)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.testReceipt.rawValue, 21007)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.productionEnvironment.rawValue, 21008)
        XCTAssertEqual(SwiftyReceiptResponse.StatusCode.receiptCouldNotBeAuthorized.rawValue, 21010)
    }
}
