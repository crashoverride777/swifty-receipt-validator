import Foundation

public struct SRVPurchaseValidationRequest {
    let productIdentifier: String
    let sharedSecret: String?
    
    /// SRVPurchaseValidationRequest
    ///
    /// - parameter productIdentifier: The product identifier of the purchase to validate.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    public init(productIdentifier: String, sharedSecret: String?) {
        self.productIdentifier = productIdentifier
        self.sharedSecret = sharedSecret
    }
}
