import Foundation

public extension SRVPendingRenewalInfo {
    static func mock(
        productId: String? = UUID().uuidString,
        autoRenewProductId: String? = UUID().uuidString,
        originalTransactionId: String? = UUID().uuidString,
        autoRenewStatus: SRVAutoRenewStatus? = .on) -> SRVPendingRenewalInfo {
        SRVPendingRenewalInfo(
            productId: productId,
            autoRenewProductId: autoRenewProductId,
            originalTransactionId: originalTransactionId,
            autoRenewStatus: autoRenewStatus
        )
    }
}
