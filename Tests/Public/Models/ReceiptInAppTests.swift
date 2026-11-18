import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ReceiptInAppTests {

    // MARK: Expiration Intent
    
    @Test func testExpirationIntentRawValue() {
        #expect(SRVReceiptInApp.ExpirationIntent.cancelled.rawValue == "1")
        #expect(SRVReceiptInApp.ExpirationIntent.billingError.rawValue == "2")
        #expect(SRVReceiptInApp.ExpirationIntent.notAggreedToPriceIncrease.rawValue == "3")
        #expect(SRVReceiptInApp.ExpirationIntent.productNotAvailable.rawValue == "4")
        #expect(SRVReceiptInApp.ExpirationIntent.unknown.rawValue == "5")
    }
    
    // MARK: Expiration Retry
    
    @Test func testExpirationRetryRawValue() {
        #expect(SRVReceiptInApp.ExpirationRetry.stoppedTryingToRenew.rawValue == "0")
        #expect(SRVReceiptInApp.ExpirationRetry.stillTryingToRenew.rawValue == "1")
    }
    
    // MARK: Cancellation Reason
    
    @Test func testCancellationReasonRawValue() {
        #expect(SRVReceiptInApp.CancellationReason.cancelledForOtherReason.rawValue == "0")
        #expect(SRVReceiptInApp.CancellationReason.customerCancelledDueToErrorInApp.rawValue == "1")
    }
    
    // MARK: Price Consent Status
    
    @Test func testPriceConsentStatusRawValue() {
        #expect(SRVReceiptInApp.PriceConsentStatus.notTakenActionForIncreasedPrice.rawValue == "0")
        #expect(SRVReceiptInApp.PriceConsentStatus.aggreedToPriceIncrease.rawValue == "1")
    }
    
    // MARK: Can Show Introductory Price
    
    @Test func testCanShowIntroductoryPrice_isTrialPeriod_returnsFalse() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "true", isInIntroOfferPeriod: "false")
        #expect(!sut.canShowIntroductoryPrice)
    }

    @Test func testCanShowIntroductoryPrice_isInIntroOfferPeriod_returnsFalse() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "false", isInIntroOfferPeriod: "true")
        #expect(!sut.canShowIntroductoryPrice)
    }

    @Test func testCanShowIntroductoryPrice_isNotTrialPeriod_isNotInIntroOfferPeriod_returnsTrue() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "false", isInIntroOfferPeriod: "false")
        #expect(sut.canShowIntroductoryPrice)
    }
}
