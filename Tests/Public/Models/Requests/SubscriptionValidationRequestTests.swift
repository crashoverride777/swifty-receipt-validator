import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct SubscriptionValidationRequestTests {

    @Test func initialization() {
        let sharedSecret = "secret"
        let refreshLocalReceiptIfNeeded = true
        let excludeOldTransactions = false
        let now: Date = .test
        
        let sut = SRVSubscriptionValidationRequest(
            sharedSecret: sharedSecret,
            refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,
            excludeOldTransactions: excludeOldTransactions,
            now: now
        )
        
        #expect(sut.sharedSecret == sharedSecret)
        #expect(sut.refreshLocalReceiptIfNeeded == refreshLocalReceiptIfNeeded)
        #expect(sut.excludeOldTransactions == excludeOldTransactions)
        #expect(sut.now == now)
    }
}
