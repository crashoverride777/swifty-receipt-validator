import XCTest
@testable import SwiftyReceiptValidator

final class ReceiptResponseTests: XCTestCase {
    
    // MARK: Valid Subscription Receipts
    
    func testValidSubscriptionReceipts_latestReceiptInfo_filters() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(cancellationDate: .test),
            .mock(expiresDate: nil),
            .mock(expiresDate: Date.test.addingTimeInterval(-10)),
            .mock(expiresDate: Date.test.addingTimeInterval(10)),
        ]
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: expectedReceiptsInApp)
        XCTAssertEqual(expectedResponse.validSubscriptionReceipts(now: .test), [expectedReceiptsInApp.last])
    }
    
    func testValidSubscriptionReceipts_latestReceiptInfo_sortsByLargerDate() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(expiresDate: Date.test.addingTimeInterval(10)),
            .mock(expiresDate: Date.test.addingTimeInterval(100))
        ]
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: expectedReceiptsInApp)
        XCTAssertEqual(
            expectedResponse.validSubscriptionReceipts(now: .test),
            [expectedReceiptsInApp.last, expectedReceiptsInApp.first]
        )
    }
    
    func testValidSubscriptionReceipts_receiptInApp_filters() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(cancellationDate: .test),
            .mock(expiresDate: nil),
            .mock(expiresDate: Date.test.addingTimeInterval(-10)),
            .mock(expiresDate: Date.test.addingTimeInterval(10)),
        ]
        let expectedResponse: SRVReceiptResponse = .mock(
            receipt: .mock(inApp: expectedReceiptsInApp),
            latestReceiptInfo: nil
        )
        XCTAssertEqual(expectedResponse.validSubscriptionReceipts(now: .test), [expectedReceiptsInApp.last])
    }
    
    func testValidSubscriptionReceipts_receiptInApp_sortsByLargerDate() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(expiresDate: Date.test.addingTimeInterval(10)),
            .mock(expiresDate: Date.test.addingTimeInterval(100))
        ]
        
        let expectedResponse: SRVReceiptResponse = .mock(
            receipt: .mock(inApp: expectedReceiptsInApp),
            latestReceiptInfo: nil
        )
        
        XCTAssertEqual(
            expectedResponse.validSubscriptionReceipts(now: .test),
            [expectedReceiptsInApp.last, expectedReceiptsInApp.first]
        )
    }
    
    func testValidSubscriptionReceipts_noLatestReceiptInfo_andNoReceiptInApp_returnsEmpty() {
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: nil)
        XCTAssertEqual(expectedResponse.validSubscriptionReceipts(now: .test), [])
    }
}
