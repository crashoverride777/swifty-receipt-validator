//
//  ReceiptInAppTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class ReceiptInAppTests: XCTestCase {

    // MARK: Expiration Intent
    
    func test_expirationIntent_rawValue_cancelled() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.cancelled.rawValue, "1")
    }
    
    func test_expirationIntent_rawValue_billingError() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.billingError.rawValue, "2")
    }
    
    func test_expirationIntent_rawValue_notAggreedToPriceIncrease() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.notAggreedToPriceIncrease.rawValue, "3")
    }
    
    func test_expirationIntent_rawValue_productNotAvailable() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.productNotAvailable.rawValue, "4")
    }
    
    func test_expirationIntent_rawValue_unknown() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationIntent.unknown.rawValue, "5")
    }
    
    // MARK: Expiration Retry
    
    func test_expirationRetry_rawValue_stoppedTryingToRenew() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationRetry.stoppedTryingToRenew.rawValue, "0")
    }
    
    func test_expirationRetry_rawValue_stillTryingToRenew() {
        XCTAssertEqual(SwiftyReceiptInApp.ExpirationRetry.stillTryingToRenew.rawValue, "1")
    }
    
    // MARK: Cancellation Reason
    
    func test_cancellationReason_rawValue_cancelledForOtherReason() {
        XCTAssertEqual(SwiftyReceiptInApp.CancellationReason.cancelledForOtherReason.rawValue, "0")
    }
    
    func test_cancellationReason_rawValue_customerCancelledDueToErrorInApp() {
        XCTAssertEqual(SwiftyReceiptInApp.CancellationReason.customerCancelledDueToErrorInApp.rawValue, "1")
    }
   
    // MARK: Auto Renew Status
    
    func test_autoRenewStatus_rawValue_off() {
        XCTAssertEqual(SwiftyReceiptInApp.AutoRenewStatus.off.rawValue, "0")
    }
    
    func test_autoRenewStatus_rawValue_on() {
        XCTAssertEqual(SwiftyReceiptInApp.AutoRenewStatus.on.rawValue, "1")
    }
    
    // MARK: Price Consent Status
    
    func test_priceConsentStatus_rawValue_notTakenActionForIncreasedPrice() {
        XCTAssertEqual(SwiftyReceiptInApp.PriceConsentStatus.notTakenActionForIncreasedPrice.rawValue, "0")
    }
    
    func test_priceConsentStatus_rawValue_aggreedToPriceIncrease() {
        XCTAssertEqual(SwiftyReceiptInApp.PriceConsentStatus.aggreedToPriceIncrease.rawValue, "1")
    }
    
    // MARK: - Can Show Introductory Price
    
    func test_canShowIntroductoryPrice_isTrialPeriod_returnsFalse() {
        let sut: SwiftyReceiptInApp = .mock(isTrialPeriod: "true")
        XCTAssertFalse(sut.canShowIntroductoryPrice)
    }

    func test_canShowIntroductoryPrice_isInIntroOfferPeriod_returnsFalse() {
        let sut: SwiftyReceiptInApp = .mock(isInIntroOfferPeriod: "true")
        XCTAssertFalse(sut.canShowIntroductoryPrice)
    }

    func test_canShowIntroductoryPrice_returnsTrue() {
        let sut: SwiftyReceiptInApp = .mock()
        XCTAssertTrue(sut.canShowIntroductoryPrice)
    }
}
