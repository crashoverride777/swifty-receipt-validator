import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ReceiptInAppTests {

    // MARK: Expiration Intent
    
    @Test func expirationIntentRawValue() {
        #expect(SRVReceiptInApp.ExpirationIntent.cancelled.rawValue == "1")
        #expect(SRVReceiptInApp.ExpirationIntent.billingError.rawValue == "2")
        #expect(SRVReceiptInApp.ExpirationIntent.notAggreedToPriceIncrease.rawValue == "3")
        #expect(SRVReceiptInApp.ExpirationIntent.productNotAvailable.rawValue == "4")
        #expect(SRVReceiptInApp.ExpirationIntent.unknown.rawValue == "5")
    }
    
    // MARK: Expiration Retry
    
    @Test func expirationRetryRawValue() {
        #expect(SRVReceiptInApp.ExpirationRetry.stoppedTryingToRenew.rawValue == "0")
        #expect(SRVReceiptInApp.ExpirationRetry.stillTryingToRenew.rawValue == "1")
    }
    
    // MARK: Cancellation Reason
    
    @Test func cancellationReasonRawValue() {
        #expect(SRVReceiptInApp.CancellationReason.cancelledForOtherReason.rawValue == "0")
        #expect(SRVReceiptInApp.CancellationReason.customerCancelledDueToErrorInApp.rawValue == "1")
    }
    
    // MARK: Price Consent Status
    
    @Test func priceConsentStatusRawValue() {
        #expect(SRVReceiptInApp.PriceConsentStatus.notTakenActionForIncreasedPrice.rawValue == "0")
        #expect(SRVReceiptInApp.PriceConsentStatus.aggreedToPriceIncrease.rawValue == "1")
    }
    
    // MARK: - Can Show Introductory Price
    
    @Test func canShowIntroductoryPrice_whenTrialPeriod_returnsFalse() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "true", isInIntroOfferPeriod: "false")
        #expect(!sut.canShowIntroductoryPrice)
    }

    @Test func canShowIntroductoryPrice_whenInIntroOfferPeriod_returnsFalse() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "false", isInIntroOfferPeriod: "true")
        #expect(!sut.canShowIntroductoryPrice)
    }

    @Test func canShowIntroductoryPrice_whenNotTrialPeriod_andNotInIntroOfferPeriod_returnsTrue() {
        let sut: SRVReceiptInApp = .mock(isTrialPeriod: "false", isInIntroOfferPeriod: "false")
        #expect(sut.canShowIntroductoryPrice)
    }
}
