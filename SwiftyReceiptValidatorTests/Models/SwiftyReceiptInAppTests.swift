//
//  SwiftyReceiptInAppTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class SwiftyReceiptInAppTests: XCTestCase {

    func test_receiptInApp_canShowIntroductoryPrice_isTrialPeriod_returnsFalse() {
        let sut: SwiftyReceiptInApp = .fake(isTrialPeriod: "true")
        XCTAssertFalse(sut.canShowIntroductoryPrice)
    }
    
    func test_receiptInApp_canShowIntroductoryPrice_isInIntroOfferPeriod_returnsFalse() {
        let sut: SwiftyReceiptInApp = .fake(isInIntroOfferPeriod: "true")
        XCTAssertFalse(sut.canShowIntroductoryPrice)
    }
    
    func test_receiptInApp_canShowIntroductoryPrice_returnsTrue() {
        let sut: SwiftyReceiptInApp = .fake()
        XCTAssertTrue(sut.canShowIntroductoryPrice)
    }
  
    func test_receiptInApp_expirationIntent() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.cancelled.rawValue, "1")
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.billingError.rawValue, "2")
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.notAggreedToPriceIncrease.rawValue, "3")
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.productNotAvailable.rawValue, "4")
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.unknown.rawValue, "5")
    }
    
    func test_receiptInApp_expirationRetry() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationRetry.stoppedTryingToRenew.rawValue, "0")
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationRetry.stillTryingToRenew.rawValue, "1")
    }
    
    func test_receiptInApp_cancellationReason() {
        XCTAssertEqual(SwiftyReceiptInApp.CancellationReason.cancelledForOtherReason.rawValue, "0")
        XCTAssertEqual(SwiftyReceiptInApp.CancellationReason.customerCancelledDueToErrorInApp.rawValue, "1")
    }
   
    func test_receiptInApp_autoRenewStatus() {
        XCTAssertEqual(SwiftyReceiptInApp.AutoRenewStatus.off.rawValue, "0")
        XCTAssertEqual(SwiftyReceiptInApp.AutoRenewStatus.on.rawValue, "1")
    }
}
