import XCTest
@testable import SwiftyReceiptValidator

class PurchaseValidationRequestTests: XCTestCase {

    func test_init() {
        let productId = "123"
        let sharedSecret = "secret"
       
        let sut = SRVPurchaseValidationRequest(
            productId: productId,
            sharedSecret: sharedSecret
        )
        
        XCTAssertEqual(sut.productId, productId)
        XCTAssertEqual(sut.sharedSecret, sharedSecret)
    }
}
