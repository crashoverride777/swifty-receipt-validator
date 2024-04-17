import XCTest
@testable import SwiftyReceiptValidator

final class SubscriptionValidationRequestTests: XCTestCase {

    func testInit() {
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
