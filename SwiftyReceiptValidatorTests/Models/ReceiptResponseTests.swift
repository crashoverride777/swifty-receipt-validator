//
//  ReceiptResponseTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class ReceiptResponseTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: SwiftyReceiptResponse!
    
    // MARK: - Life Cycle
    
    override func setUp() {
        super.setUp()
        sut = .fake(.subscription)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    #warning("add tests/finish")
    // MARK: - Tests
    
    // MARK: Valid Subscription Receipts
    
    func test_validSubscriptionReceipts() {
        let expectedResponse: SRVReceiptResponse = .mock()
    }
}
