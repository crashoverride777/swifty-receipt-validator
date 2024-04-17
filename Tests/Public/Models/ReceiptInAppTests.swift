import XCTest
@testable import SwiftyReceiptValidator

final class ReceiptInAppTests: XCTestCase {

    // MARK: Expiration Intent
    
    func testExpirationIntentRawValue() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.cancelled.rawValue, "1")
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.billingError.rawValue, "2")
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.notAggreedToPriceIncrease.rawValue, "3")
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.productNotAvailable.rawValue, "4")
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.unknown.rawValue, "5")
    }
    
    // MARK: Expiration Retry
    
    func testExpirationRetryRawValue() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationRetry.stoppedTryingToRenew.rawValue, "0")
        XCTAssertEqual(SRVReceiptInApp.ExpirationRetry.stillTryingToRenew.rawValue, "1")
    }
    
    // MARK: Cancellation Reason
    
    func testCancellationReasonRawValue() {
        XCTAssertEqual(SRVReceiptInApp.CancellationReason.cancelledForOtherReason.rawValue, "0")
        XCTAssertEqual(SRVReceiptInApp.CancellationReason.customerCancelledDueToErrorInApp.rawValue, "1")
    }
    
    // MARK: Price Consent Status
    
    func testPriceConsentStatusRawValue() {
        XCTAssertEqual(SRVReceiptInApp.PriceConsentStatus.notTakenActionForIncreasedPrice.rawValue, "0")
        XCTAssertEqual(SRVReceiptInApp.PriceConsentStatus.aggreedToPriceIncrease.rawValue, "1")
    }
    
    // MARK: - Can Show Introductory Price
    
    func testCanShowIntroductoryPrice_isTrialPeriod_returnsFalse() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "true", isInIntroOfferPeriod: "false")
        XCTAssertFalse(sut.canShowIntroductoryPrice)
    }

    func testCanShowIntroductoryPrice_isInIntroOfferPeriod_returnsFalse() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "false", isInIntroOfferPeriod: "true")
        XCTAssertFalse(sut.canShowIntroductoryPrice)
    }

    func testCanShowIntroductoryPrice_isNotTrialPeriod_isNotInIntroOfferPeriod_returnsTrue() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "false", isInIntroOfferPeriod: "false")
        XCTAssertTrue(sut.canShowIntroductoryPrice)
    }
}
