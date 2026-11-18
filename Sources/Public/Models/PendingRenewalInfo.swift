import Foundation

public struct SRVPendingRenewalInfo: Equatable, Sendable, Codable {
    public let productId: String?
    public let autoRenewProductId: String?
    public let originalTransactionId: String?
    public let autoRenewStatus: SRVAutoRenewStatus?
}
