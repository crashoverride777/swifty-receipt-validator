import Foundation

public struct SRVSubscriptionValidationResponse: Equatable, Sendable {
    public let validSubscriptionReceipts: [SRVReceiptInApp]
    public let receiptResponse: SRVReceiptResponse
}
