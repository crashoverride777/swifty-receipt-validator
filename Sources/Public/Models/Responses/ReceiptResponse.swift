import Foundation

public struct SRVReceiptResponse: Codable, Equatable {
    // For iOS 6 style transaction receipts, the status code reflects the status of the specific transaction’s receipt.
    // For iOS 7 style app receipts, the status code is reflects the status of the app receipt as a whole. For example, if you send a valid app receipt that contains an expired subscription, the response is 0 because the receipt as a whole is valid.
    public let status: SRVStatusCode
    // A JSON representation of the receipt that was sent for verification. For information about keys found in a receipt, see Receipt Fields.
    public let receipt: SRVReceipt?
    // Only returned for receipts containing auto-renewable subscriptions.
    // For iOS 6 style transaction receipts, this is the base-64 encoded receipt for the most recent renewal.
    // For iOS 7 style app receipts, this is the latest base-64 encoded app receipt.
    public let latestReceipt: Data?
    // Only returned for receipts containing auto-renewable subscriptions.
    // For iOS 6 style transaction receipts, this is the JSON representation of the receipt for the most recent renewal.
    // For iOS 7 style app receipts, the value of this key is an array containing all in-app purchase transactions. This excludes transactions for a consumable product that have been marked as finished by your app.
    public let latestReceiptInfo: [SRVReceiptInApp]?
    // Only returned for iOS 7 style app receipts containing auto-renewable subscriptions. In the JSON file, the value of this key is an array where each element contains the pending renewal information for each auto-renewable subscription identified by the Product Identifier. A pending renewal may refer to a renewal that is scheduled in the future or a renewal that failed in the past for some reason.
    public let pendingRenewalInfo: [SRVPendingRenewalInfo]?
    // The current environment, Sandbox or Production
    public let environment: String?
}

// MARK: - Computed

extension SRVReceiptResponse {
    
    /// All subscriptions that are currently active, sorted by expiry dates
    func validSubscriptionReceipts(now: Date) -> [SRVReceiptInApp] {
        guard let receipts = latestReceiptInfo ?? receipt?.inApp else {
            return []
        }
        
        return receipts
            // Filter receipts for subsriptions
            .filter {
                /*
                 To check whether a purchase has been cancelled by Apple Customer Support, look for the
                 Cancellation Date field in the receipt. If the field contains a date, regardless
                 of the subscription’s expiration date, the purchase has been cancelled. With respect to
                 providing content or service, treat a canceled transaction the same as if no purchase
                 had ever been made.
                 */
                guard $0.cancellationDate == nil else {
                    return false
                }
                
                // Only receipts with an expiry date are subscriptions
                guard let expiresDate = $0.expiresDate else {
                    return false
                }
                
                // Return active subscription receipts
                return expiresDate >= now
            }
            // Sort subscription receipts by expiry date
            // We can force unwrap as nil expiry dates get filtered above
            .sorted(by: { $0.expiresDate! > $1.expiresDate! })
    }
}
