//
//  AutoRenewStatusTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class AutoRenewStatusTests: XCTestCase {
    
    func test_rawValue_off() {
        XCTAssertEqual(SRVAutoRenewStatus.off.rawValue, "0")
    }
    
    func test_rawValue_on() {
        XCTAssertEqual(SRVAutoRenewStatus.on.rawValue, "1")
    }
}
