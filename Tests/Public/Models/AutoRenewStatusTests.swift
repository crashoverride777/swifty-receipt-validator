import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct AutoRenewStatusTests {
    
    @Test func rawValue() {
        #expect(SRVAutoRenewStatus.off.rawValue == "0")
        #expect(SRVAutoRenewStatus.on.rawValue == "1")
    }
}
