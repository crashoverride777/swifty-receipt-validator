import XCTest
@testable import SwiftyReceiptValidator

final class ErrorTests: XCTestCase {
    
    // MARK: - Status Code
    
    func testStatusCode_whenNoReceiptFoundInBundle() {
        XCTAssertEqual(SRVError.noReceiptFoundInBundle.statusCode, nil)
    }
    
    func testStatusCode_whenInvalidStatusCode() {
        XCTAssertEqual(SRVError.invalidStatusCode(.valid).statusCode, .valid)
    }
    
    func testStatusCode_whenNoReceiptFoundInResponse() {
        XCTAssertEqual(SRVError.noReceiptFoundInResponse(.valid).statusCode, .valid)
    }
    
    func testStatusCode_whenBundleIdNotMatching() {
        XCTAssertEqual(SRVError.bundleIdNotMatching(.valid).statusCode, .valid)
    }
    
    func testStatusCode_whenProductIdNotMatching() {
        XCTAssertEqual(SRVError.productIdNotMatching(.valid).statusCode, .valid)
    }
    
    func testStatusCode_whenNoValidSubscription() {
        XCTAssertEqual(SRVError.subscriptioniOS6StyleExpired(.valid).statusCode, .valid)
    }
    
    func testStatusCode_whenPurchaseCancelled() {
        XCTAssertEqual(SRVError.purchaseCancelled(.valid).statusCode, .valid)
    }
    
    func testStatusCode_whenOtherError() {
        let expectedError = URLError(.notConnectedToInternet)
        XCTAssertNil(SRVError.other(expectedError).statusCode)
    }
}
