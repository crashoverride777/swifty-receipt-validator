import Foundation

public struct SRVPendingRenewalInfo: Codable, Equatable {
    public let productId: String?
    public let autoRenewProductId: String?
    public let originalTransactionId: String?
    public let autoRenewStatus: SRVAutoRenewStatus?
}
