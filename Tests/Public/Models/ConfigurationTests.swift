import Foundation
import XCTest
@testable import SwiftyReceiptValidator

class ConfigurationTests: XCTestCase {
    
    func test_standard() {
        let sut: SRVConfiguration = .standard
        XCTAssertEqual(sut.productionURL, "https://buy.itunes.apple.com/verifyReceipt")
        XCTAssertEqual(sut.sandboxURL, "https://sandbox.itunes.apple.com/verifyReceipt")
        XCTAssertEqual(sut.sessionConfiguration, .default)
    }
    
    func test_custom() {
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "identifier")
        sessionConfiguration.httpAdditionalHeaders = ["key": "value"]

        let sut = SRVConfiguration(
            productionURL: "production",
            sandboxURL: "sandbox",
            sessionConfiguration: sessionConfiguration
        )
        XCTAssertEqual(sut.productionURL, "production")
        XCTAssertEqual(sut.sandboxURL, "sandbox")
        XCTAssertEqual(sut.sessionConfiguration, sessionConfiguration)
    }
}
