import Foundation

public struct SRVSubscriptionValidationResponse: Equatable {
    public let validSubscriptionReceipts: [SRVReceiptInApp]
    public let receiptResponse: SRVReceiptResponse
}
