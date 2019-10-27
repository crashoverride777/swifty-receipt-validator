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
    
    private var sut: SwiftyReceiptValidator!
    private var sessionManager: MockSessionManager!
    
    // MARK: - Life Cycle
    
    override func setUp() {
        super.setUp()
        sessionManager = MockSessionManager()
    }

    override func tearDown() {
        sut = nil
        sessionManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    // MARK: Config
    
    func test_config() {
        makeSUT(configuration: .standard)
        let productionURL = "https://buy.itunes.apple.com/verifyReceipt"
        let sandboxURL = "https://sandbox.itunes.apple.com/verifyReceipt"
        XCTAssertTrue(sut.configuration.productionURL == productionURL)
        XCTAssertTrue(sut.configuration.sandboxURL == sandboxURL)
        XCTAssertTrue(sut.configuration.sessionConfiguration == .default)
    }
}

// MARK: - Private Methods

private extension SwiftyReceiptValidatorTests {
    
    func makeSUT(configuration: SwiftyReceiptValidator.Configuration) {
        sut = SwiftyReceiptValidator(
            configuration: configuration,
            sessionManager: sessionManager,
            validator: DefaultValidator()
        )
    }
}
