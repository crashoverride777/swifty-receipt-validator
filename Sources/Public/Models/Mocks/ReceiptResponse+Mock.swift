import Foundation

public extension SRVReceiptResponse {
    static func mock(
        statusCode: SRVStatusCode = .valid,
        receipt: SRVReceipt? = .mock(),
        latestReceipt: Data? = nil,
        latestReceiptInfo: [SRVReceiptInApp]? = [.mock()],
        pendingRenewalInfo: [SRVPendingRenewalInfo]? = [.mock()],
        environment: String? = nil) -> SRVReceiptResponse {
        SRVReceiptResponse(
            status: statusCode,
            receipt: receipt,
            latestReceipt: latestReceipt,
            latestReceiptInfo: latestReceiptInfo,
            pendingRenewalInfo: pendingRenewalInfo,
            environment: environment
        )
    }
}
