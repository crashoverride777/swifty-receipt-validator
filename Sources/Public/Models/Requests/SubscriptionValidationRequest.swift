import Foundation

public struct SRVSubscriptionValidationRequest: Equatable, Sendable {
    public let sharedSecret: String?
    public let refreshLocalReceiptIfNeeded: Bool
    public let excludeOldTransactions: Bool
    public let now: Date
    
    /// SRVSubscriptionValidationRequest
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter now: The current date.
    public init(sharedSecret: String?,
                refreshLocalReceiptIfNeeded: Bool,
                excludeOldTransactions: Bool,
                now: Date) {
        self.sharedSecret = sharedSecret
        self.refreshLocalReceiptIfNeeded = refreshLocalReceiptIfNeeded
        self.excludeOldTransactions = excludeOldTransactions
        self.now = now
    }
}
