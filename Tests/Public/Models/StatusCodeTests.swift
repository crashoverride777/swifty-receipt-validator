import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct StatusCodeTests {
        
    // MARK: Raw Value
    
    @Test func testRawValue() {
        #expect(SRVStatusCode.unknown.rawValue == -1)
        #expect(SRVStatusCode.valid.rawValue == 0)
        #expect(SRVStatusCode.jsonNotReadable.rawValue == 21000)
        #expect(SRVStatusCode.malformedOrMissingData.rawValue == 21002)
        #expect(SRVStatusCode.receiptCouldNotBeAuthenticated.rawValue == 21003)
        #expect(SRVStatusCode.sharedSecretNotMatching.rawValue == 21004)
        #expect(SRVStatusCode.receiptServerUnavailable.rawValue == 21005)
        #expect(SRVStatusCode.subscriptioniOS6StyleExpired.rawValue == 21006)
        #expect(SRVStatusCode.testReceipt.rawValue == 21007)
        #expect(SRVStatusCode.productionEnvironment.rawValue == 21008)
        #expect(SRVStatusCode.receiptCouldNotBeAuthorized.rawValue == 21010)
        #expect(SRVStatusCode.internalDataAccessError.rawValue == 21100)
    }
    
    // MARK: Is Valid
    
    @Test func testIsValid_whenUnknown_returnsFalse() {
        let sut: SRVStatusCode = .unknown
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenValidStatusCode_returnsTrue() {
        let sut: SRVStatusCode = .valid
        #expect(sut.isValid)
    }
    
    @Test func testIsValid_whenJSONNotReadable_returnsFalse() {
        let sut: SRVStatusCode = .jsonNotReadable
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenMalformedOrMissingData_returnsFalse() {
        let sut: SRVStatusCode = .malformedOrMissingData
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenReceiptCouldNotBeAuthenticated_returnsFalse() {
        let sut: SRVStatusCode = .receiptCouldNotBeAuthenticated
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenSharedSecretNotMatching_returnsFalse() {
        let sut: SRVStatusCode = .sharedSecretNotMatching
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenReceiptServerUnavailable_returnsFalse() {
        let sut: SRVStatusCode = .receiptServerUnavailable
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenSubscriptionExpired_returnsTrue() {
        let sut: SRVStatusCode = .subscriptioniOS6StyleExpired
        #expect(sut.isValid)
    }
    
    @Test func testIsValid_whenTestReceipt_returnsFalse() {
        let sut: SRVStatusCode = .testReceipt
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenProductionEnvironment_returnsFalse() {
        let sut: SRVStatusCode = .productionEnvironment
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenReceiptCouldNotBeAuthorized_returnsFalse() {
        let sut: SRVStatusCode = .receiptCouldNotBeAuthorized
        #expect(!sut.isValid)
    }
    
    @Test func testIsValid_whenInternalDataAccessError_returnsFalse() {
        let sut: SRVStatusCode = .internalDataAccessError
        #expect(!sut.isValid)
    }
}
