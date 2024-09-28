import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct PurchaseValidationRequestTests {

    @Test func initialization() {
        let sut = SRVPurchaseValidationRequest(productIdentifier: "123", sharedSecret: "sharedSecret")
        #expect(sut.productIdentifier == "123")
        #expect(sut.sharedSecret == "sharedSecret")
    }
}
