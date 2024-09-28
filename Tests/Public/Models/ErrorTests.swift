import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ErrorTests {
    
    @Test func statusCode() {
        #expect(SRVError.noReceiptFoundInBundle.statusCode == nil)
        #expect(SRVError.invalidStatusCode(.valid).statusCode == .valid)
        #expect(SRVError.noReceiptFoundInResponse(.valid).statusCode == .valid)
        #expect(SRVError.bundleIdNotMatching(.valid).statusCode == .valid)
        #expect(SRVError.productIdNotMatching(.valid).statusCode == .valid)
        #expect(SRVError.subscriptioniOS6StyleExpired(.valid).statusCode == .valid)
        #expect(SRVError.purchaseCancelled(.valid).statusCode == .valid)
    }
}
