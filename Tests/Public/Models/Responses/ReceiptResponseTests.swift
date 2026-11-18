import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ReceiptResponseTests {
    
    @Test func testValidSubscriptionReceipts_latestReceiptInfo_filters() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(cancellationDate: .test),
            .mock(expiresDate: nil),
            .mock(expiresDate: Date.test.addingTimeInterval(-10)),
            .mock(expiresDate: Date.test.addingTimeInterval(10)),
        ]
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: expectedReceiptsInApp)
        #expect(expectedResponse.validSubscriptionReceipts(now: .test) == [expectedReceiptsInApp.last])
    }
    
    @Test func testValidSubscriptionReceipts_latestReceiptInfo_sortsByLargerDate() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(expiresDate: Date.test.addingTimeInterval(10)),
            .mock(expiresDate: Date.test.addingTimeInterval(100))
        ]
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: expectedReceiptsInApp)
        #expect(
            expectedResponse.validSubscriptionReceipts(now: .test) ==
            [expectedReceiptsInApp.last, expectedReceiptsInApp.first]
        )
    }
    
    @Test func testValidSubscriptionReceipts_receiptInApp_filters() {
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
        #expect(expectedResponse.validSubscriptionReceipts(now: .test) == [expectedReceiptsInApp.last])
    }
    
    @Test func testValidSubscriptionReceipts_receiptInApp_sortsByLargerDate() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(expiresDate: Date.test.addingTimeInterval(10)),
            .mock(expiresDate: Date.test.addingTimeInterval(100))
        ]
        
        let expectedResponse: SRVReceiptResponse = .mock(
            receipt: .mock(inApp: expectedReceiptsInApp),
            latestReceiptInfo: nil
        )
        
        #expect(
            expectedResponse.validSubscriptionReceipts(now: .test) ==
            [expectedReceiptsInApp.last, expectedReceiptsInApp.first]
        )
    }
    
    @Test func testValidSubscriptionReceipts_noLatestReceiptInfo_andNoReceiptInApp_returnsEmpty() {
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: nil)
        #expect(expectedResponse.validSubscriptionReceipts(now: .test).isEmpty)
    }
}
