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
    
    func test_rawValue() {
        XCTAssertEqual(SRVAutoRenewStatus.off.rawValue, "0")
        XCTAssertEqual(SRVAutoRenewStatus.on.rawValue, "1")
    }
}
