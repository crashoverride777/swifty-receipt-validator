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

    // MARK: - Life Cycle
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    // MARK: Config
    
    func test_config() {
        sut = SwiftyReceiptValidator(configuration: .standard)
        let productionURL = "https://buy.itunes.apple.com/verifyReceipt"
        let sandboxURL = "https://sandbox.itunes.apple.com/verifyReceipt"
        XCTAssertTrue(sut.configuration.productionURL == productionURL)
        XCTAssertTrue(sut.configuration.sandboxURL == sandboxURL)
    }
}
