import XCTest
@testable import SwiftyReceiptValidator

final class StatusCodeTests: XCTestCase {
        
    // MARK: Raw Value
    
    func testRawValue() {
        XCTAssertEqual(SRVStatusCode.unknown.rawValue, -1)
        XCTAssertEqual(SRVStatusCode.valid.rawValue, 0)
        XCTAssertEqual(SRVStatusCode.jsonNotReadable.rawValue, 21000)
        XCTAssertEqual(SRVStatusCode.malformedOrMissingData.rawValue, 21002)
        XCTAssertEqual(SRVStatusCode.receiptCouldNotBeAuthenticated.rawValue, 21003)
        XCTAssertEqual(SRVStatusCode.sharedSecretNotMatching.rawValue, 21004)
        XCTAssertEqual(SRVStatusCode.receiptServerUnavailable.rawValue, 21005)
        XCTAssertEqual(SRVStatusCode.subscriptioniOS6StyleExpired.rawValue, 21006)
        XCTAssertEqual(SRVStatusCode.testReceipt.rawValue, 21007)
        XCTAssertEqual(SRVStatusCode.productionEnvironment.rawValue, 21008)
        XCTAssertEqual(SRVStatusCode.receiptCouldNotBeAuthorized.rawValue, 21010)
        XCTAssertEqual(SRVStatusCode.internalDataAccessError.rawValue, 21100)
    }
    
    // MARK: Is Valid
    
    func testIsValid_whenUnknown_returnsFalse() {
        let sut: SRVStatusCode = .unknown
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenValidStatusCode_returnsTrue() {
        let sut: SRVStatusCode = .valid
        XCTAssertTrue(sut.isValid)
    }
    
    func testIsValid_whenJSONNotReadable_returnsFalse() {
        let sut: SRVStatusCode = .jsonNotReadable
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenMalformedOrMissingData_returnsFalse() {
        let sut: SRVStatusCode = .malformedOrMissingData
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenReceiptCouldNotBeAuthenticated_returnsFalse() {
        let sut: SRVStatusCode = .receiptCouldNotBeAuthenticated
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenSharedSecretNotMatching_returnsFalse() {
        let sut: SRVStatusCode = .sharedSecretNotMatching
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenReceiptServerUnavailable_returnsFalse() {
        let sut: SRVStatusCode = .receiptServerUnavailable
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenSubscriptionExpired_returnsTrue() {
        let sut: SRVStatusCode = .subscriptioniOS6StyleExpired
        XCTAssertTrue(sut.isValid)
    }
    
    func testIsValid_whenTestReceipt_returnsFalse() {
        let sut: SRVStatusCode = .testReceipt
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenProductionEnvironment_returnsFalse() {
        let sut: SRVStatusCode = .productionEnvironment
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenReceiptCouldNotBeAuthorized_returnsFalse() {
        let sut: SRVStatusCode = .receiptCouldNotBeAuthorized
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_whenInternalDataAccessError_returnsFalse() {
        let sut: SRVStatusCode = .internalDataAccessError
        XCTAssertFalse(sut.isValid)
    }
}
