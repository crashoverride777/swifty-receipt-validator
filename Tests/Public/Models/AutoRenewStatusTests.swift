import XCTest
@testable import SwiftyReceiptValidator

class AutoRenewStatusTests: XCTestCase {
    
    func test_rawValue() {
        XCTAssertEqual(SRVAutoRenewStatus.off.rawValue, "0")
        XCTAssertEqual(SRVAutoRenewStatus.on.rawValue, "1")
    }
}
