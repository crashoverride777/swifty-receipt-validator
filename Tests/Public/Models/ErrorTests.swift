import XCTest
@testable import SwiftyReceiptValidator

class ErrorTests: XCTestCase {
    
    // MARK: - Status Code
    
    func test_statusCode_whenNoReceiptFoundInBundle() {
        XCTAssertEqual(SRVError.noReceiptFoundInBundle.statusCode, nil)
    }
    
    func test_statusCode_whenInvalidStatusCode() {
        XCTAssertEqual(SRVError.invalidStatusCode(.valid).statusCode, .valid)
    }
    
    func test_statusCode_whenNoReceiptFoundInResponse() {
        XCTAssertEqual(SRVError.noReceiptFoundInResponse(.valid).statusCode, .valid)
    }
    
    func test_statusCode_whenBundleIdNotMatching() {
        XCTAssertEqual(SRVError.bundleIdNotMatching(.valid).statusCode, .valid)
    }
    
    func test_statusCode_whenProductIdNotMatching() {
        XCTAssertEqual(SRVError.productIdNotMatching(.valid).statusCode, .valid)
    }
    
    func test_statusCode_whenNoValidSubscription() {
        XCTAssertEqual(SRVError.subscriptioniOS6StyleExpired(.valid).statusCode, .valid)
    }
    
    func test_statusCode_whenPurchaseCancelled() {
        XCTAssertEqual(SRVError.purchaseCancelled(.valid).statusCode, .valid)
    }
    
    func test_statusCode_whenOtherError() {
        let expectedError = URLError(.notConnectedToInternet)
        XCTAssertNil(SRVError.other(expectedError).statusCode)
    }
}
