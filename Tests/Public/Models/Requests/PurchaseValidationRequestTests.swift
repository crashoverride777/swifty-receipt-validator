import XCTest
@testable import SwiftyReceiptValidator

final class PurchaseValidationRequestTests: XCTestCase {

    func testInit() {
        let sut = SRVPurchaseValidationRequest(productIdentifier: "123", sharedSecret: "sharedSecret")
        XCTAssertEqual(sut.productIdentifier, "123")
        XCTAssertEqual(sut.sharedSecret, "sharedSecret")
    }
}
