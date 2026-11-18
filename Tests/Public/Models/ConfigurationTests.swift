import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ConfigurationTests {
    
    @Test func testStandard() {
        let sut: SRVConfiguration = .standard
        #expect(sut.productionURL == "https://buy.itunes.apple.com/verifyReceipt")
        #expect(sut.sandboxURL == "https://sandbox.itunes.apple.com/verifyReceipt")
        #expect(sut.sessionConfiguration == .default)
    }
    
    @Test func testCustom() {
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "identifier")
        sessionConfiguration.httpAdditionalHeaders = ["key": "value"]

        let sut = SRVConfiguration(
            productionURL: "production",
            sandboxURL: "sandbox",
            sessionConfiguration: sessionConfiguration
        )
        #expect(sut.productionURL == "production")
        #expect(sut.sandboxURL == "sandbox")
        #expect(sut.sessionConfiguration == sessionConfiguration)
    }
}
