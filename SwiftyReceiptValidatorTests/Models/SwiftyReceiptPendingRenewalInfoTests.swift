//
//  SwiftyReceiptPendingRenewalInfoTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class SwiftyReceiptPendingRenewalInfoTests: XCTestCase {
    
    func test_pendingRenewalInfo_autoRenewStatus() {
        XCTAssertEqual(SwiftyReceiptPendingRenewalInfo.AutoRenewStatus.off.rawValue, "0")
        XCTAssertEqual(SwiftyReceiptPendingRenewalInfo.AutoRenewStatus.on.rawValue, "1")
    }
}
