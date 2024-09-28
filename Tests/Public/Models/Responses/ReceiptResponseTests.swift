import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ReceiptResponseTests {
    
    // MARK: Valid Subscription Receipts
    
    @Test func validSubscriptionReceipts_latestReceiptInfo_filters() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(cancellationDate: .mock),
            .mock(expiresDate: nil),
            .mock(expiresDate: Date.mock.addingTimeInterval(-10)),
            .mock(expiresDate: Date.mock.addingTimeInterval(10)),
        ]
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: expectedReceiptsInApp)
        #expect(expectedResponse.validSubscriptionReceipts(now: .mock) == [expectedReceiptsInApp.last])
    }
    
    @Test func validSubscriptionReceipts_latestReceiptInfo_sortsByLargerDate() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(expiresDate: Date.mock.addingTimeInterval(10)),
            .mock(expiresDate: Date.mock.addingTimeInterval(100))
        ]
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: expectedReceiptsInApp)
        #expect(
            expectedResponse.validSubscriptionReceipts(now: .mock) ==
            [expectedReceiptsInApp.last, expectedReceiptsInApp.first]
        )
    }
    
    @Test func validSubscriptionReceipts_receiptInApp_filters() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(cancellationDate: .mock),
            .mock(expiresDate: nil),
            .mock(expiresDate: Date.mock.addingTimeInterval(-10)),
            .mock(expiresDate: Date.mock.addingTimeInterval(10)),
        ]
        let expectedResponse: SRVReceiptResponse = .mock(
            receipt: .mock(inApp: expectedReceiptsInApp),
            latestReceiptInfo: nil
        )
        #expect(expectedResponse.validSubscriptionReceipts(now: .mock) == [expectedReceiptsInApp.last])
    }
    
    @Test func validSubscriptionReceipts_receiptInApp_sortsByLargerDate() {
        let expectedReceiptsInApp: [SRVReceiptInApp] = [
            .mock(expiresDate: Date.mock.addingTimeInterval(10)),
            .mock(expiresDate: Date.mock.addingTimeInterval(100))
        ]
        
        let expectedResponse: SRVReceiptResponse = .mock(
            receipt: .mock(inApp: expectedReceiptsInApp),
            latestReceiptInfo: nil
        )
        
        #expect(
            expectedResponse.validSubscriptionReceipts(now: .mock) ==
            [expectedReceiptsInApp.last, expectedReceiptsInApp.first]
        )
    }
    
    @Test func validSubscriptionReceipts_noLatestReceiptInfo_andNoReceiptInApp_returnsEmpty() {
        let expectedResponse: SRVReceiptResponse = .mock(receipt: nil, latestReceiptInfo: nil)
        #expect(expectedResponse.validSubscriptionReceipts(now: .mock) == [])
    }
}
