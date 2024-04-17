import XCTest
@testable import SwiftyReceiptValidator

final class AutoRenewStatusTests: XCTestCase {
    
    func testRawValue() {
        XCTAssertEqual(SRVAutoRenewStatus.off.rawValue, "0")
        XCTAssertEqual(SRVAutoRenewStatus.on.rawValue, "1")
    }
}
