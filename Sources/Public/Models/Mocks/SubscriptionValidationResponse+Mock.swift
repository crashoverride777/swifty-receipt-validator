import Foundation

public extension SRVSubscriptionValidationResponse {
    static func mock(
        validReceipts: [SRVReceiptInApp] = [.mock()],
        receiptResponse: SRVReceiptResponse = .mock()) -> SRVSubscriptionValidationResponse {
        SRVSubscriptionValidationResponse(
            validSubscriptionReceipts: validReceipts,
            receiptResponse: receiptResponse
        )
    }
}
