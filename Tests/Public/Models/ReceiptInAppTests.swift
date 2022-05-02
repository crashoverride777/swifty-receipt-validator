import XCTest
@testable import SwiftyReceiptValidator

class ReceiptInAppTests: XCTestCase {

    // MARK: Expiration Intent
    
    func test_expirationIntent_rawValue_cancelled() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.cancelled.rawValue, "1")
    }
    
    func test_expirationIntent_rawValue_billingError() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.billingError.rawValue, "2")
    }
    
    func test_expirationIntent_rawValue_notAggreedToPriceIncrease() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.notAggreedToPriceIncrease.rawValue, "3")
    }
    
    func test_expirationIntent_rawValue_productNotAvailable() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.productNotAvailable.rawValue, "4")
    }
    
    func test_expirationIntent_rawValue_unknown() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationIntent.unknown.rawValue, "5")
    }
    
    // MARK: Expiration Retry
    
    func test_expirationRetry_rawValue_stoppedTryingToRenew() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationRetry.stoppedTryingToRenew.rawValue, "0")
    }
    
    func test_expirationRetry_rawValue_stillTryingToRenew() {
        XCTAssertEqual(SRVReceiptInApp.ExpirationRetry.stillTryingToRenew.rawValue, "1")
    }
    
    // MARK: Cancellation Reason
    
    func test_cancellationReason_rawValue_cancelledForOtherReason() {
        XCTAssertEqual(SRVReceiptInApp.CancellationReason.cancelledForOtherReason.rawValue, "0")
    }
    
    func test_cancellationReason_rawValue_customerCancelledDueToErrorInApp() {
        XCTAssertEqual(SRVReceiptInApp.CancellationReason.customerCancelledDueToErrorInApp.rawValue, "1")
    }
    
    // MARK: Price Consent Status
    
    func test_priceConsentStatus_rawValue_notTakenActionForIncreasedPrice() {
        XCTAssertEqual(SRVReceiptInApp.PriceConsentStatus.notTakenActionForIncreasedPrice.rawValue, "0")
    }
    
    func test_priceConsentStatus_rawValue_aggreedToPriceIncrease() {
        XCTAssertEqual(SRVReceiptInApp.PriceConsentStatus.aggreedToPriceIncrease.rawValue, "1")
    }
    
    // MARK: - Can Show Introductory Price
    
    func test_canShowIntroductoryPrice_isTrialPeriod_returnsFalse() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "true", isInIntroOfferPeriod: "false")
        XCTAssertFalse(sut.canShowIntroductoryPrice)
    }

    func test_canShowIntroductoryPrice_isInIntroOfferPeriod_returnsFalse() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "false", isInIntroOfferPeriod: "true")
        XCTAssertFalse(sut.canShowIntroductoryPrice)
    }

    func test_canShowIntroductoryPrice_isNotTrialPeriod_isNotInIntroOfferPeriod_returnsTrue() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "false", isInIntroOfferPeriod: "false")
        XCTAssertTrue(sut.canShowIntroductoryPrice)
    }
}
