//
//  SwiftyReceiptValidatorTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 27/02/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class SwiftyReceiptValidatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var receiptFetcher: MockReceiptFetcher!
    private var sessionManager: MockSessionManager!
    private var responseValidator: MockResponseValidator!
    
    // MARK: - Life Cycle
    
    override func setUp() {
        super.setUp()
        receiptFetcher = MockReceiptFetcher()
        sessionManager = MockSessionManager()
        responseValidator = MockResponseValidator()
    }

    override func tearDown() {
        receiptFetcher = nil
        sessionManager = nil
        responseValidator = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    // MARK: Config
    
    func test_config_standard() {
        let sut = makeSUT(configuration: .standard)
        let productionURL = "https://buy.itunes.apple.com/verifyReceipt"
        let sandboxURL = "https://sandbox.itunes.apple.com/verifyReceipt"
        XCTAssertEqual(sut.configuration.productionURL, productionURL)
        XCTAssertEqual(sut.configuration.sandboxURL, sandboxURL)
        XCTAssertEqual(sut.configuration.sessionConfiguration, .default)
    }
    
    func test_config_custom() {
        let expectedConfiguration = SwiftyReceiptValidator.Configuration(
            productionURL: "https://example.com",
            sandboxURL: "https://example.sandbox.com",
            sessionConfiguration: URLSessionConfiguration()
        )
        let sut = makeSUT(configuration: expectedConfiguration)
        XCTAssertEqual(sut.configuration, expectedConfiguration)
    }
    
    // MARK: - Validate Purchase
    
    func test_validPurchasePublisher_success_publishesCorrectData() {
        
    }
    
    func test_validPurchasePublisher_failure_publishesCorrectError() {
        
    }
    
    // MARK: - Validate Subscription
    
    func test_validSubscriptionPublisher_success_publishesCorrectData() {
        
    }
    
    func test_validSubscriptionPublisher_failure_publishesCorrectError() {
        
    }
    
    // MARK: - Fetch
    
    func test_fetchPublisher_success_publishesCorrectData() {
        
    }
    
    func test_fetchPublisher_failure_publishesCorrectError() {
        
    }
}

// MARK: - Private Methods

private extension SwiftyReceiptValidatorTests {
    
    func makeSUT(configuration: SwiftyReceiptValidator.Configuration) -> SwiftyReceiptValidator {
        SwiftyReceiptValidator(
            configuration: .standard,
            receiptFetcher: receiptFetcher,
            sessionManager: sessionManager,
            responseValidator: responseValidator
        )
    }
}
