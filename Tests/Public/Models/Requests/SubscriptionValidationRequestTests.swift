import XCTest
@testable import SwiftyReceiptValidator

class SubscriptionValidationRequestTests: XCTestCase {

    func test_init() {
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
        
        XCTAssertEqual(sut.sharedSecret, sharedSecret)
        XCTAssertEqual(sut.refreshLocalReceiptIfNeeded, refreshLocalReceiptIfNeeded)
        XCTAssertEqual(sut.excludeOldTransactions, excludeOldTransactions)
        XCTAssertEqual(sut.now, now)
    }
}
