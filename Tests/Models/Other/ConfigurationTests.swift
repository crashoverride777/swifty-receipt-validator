//
//  ConfigurationTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation

import XCTest
@testable import SwiftyReceiptValidator

class ConfigurationTests: XCTestCase {
    
    func test_standard() {
        let sut: SRVConfiguration = .standard
        XCTAssertEqual(sut.productionURL, "https://buy.itunes.apple.com/verifyReceipt")
        XCTAssertEqual(sut.sandboxURL, "https://sandbox.itunes.apple.com/verifyReceipt")
        XCTAssertEqual(sut.sessionConfiguration, .default)
    }
    
    func test_custom() {
        let sut = SRVConfiguration(
            productionURL: "production",
            sandboxURL: "sandbox",
            sessionConfiguration: .default
        )
        XCTAssertEqual(sut.productionURL, "production")
        XCTAssertEqual(sut.sandboxURL, "sandbox")
        XCTAssertEqual(sut.sessionConfiguration, .default)
    }
}
