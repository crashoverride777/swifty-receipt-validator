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
    
    var sut: SwiftyReceiptValidator!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    // MARK: - Test Config

    func test_config() {
        sut = SwiftyReceiptValidator(configuration: .standard)
        let productionURL = "https://buy.itunes.apple.com/verifyReceipt"
        let sandboxURL = "https://sandbox.itunes.apple.com/verifyReceipt"
        XCTAssertTrue(sut.configuration.productionURL == productionURL)
        XCTAssertTrue(sut.configuration.sandboxURL == sandboxURL)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
