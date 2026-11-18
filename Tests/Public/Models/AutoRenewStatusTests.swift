import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct AutoRenewStatusTests {
    
    @Test func testRawValue() {
        #expect(SRVAutoRenewStatus.off.rawValue == "0")
        #expect(SRVAutoRenewStatus.on.rawValue == "1")
    }
}
