import Foundation

public struct SRVPurchaseValidationRequest {
    let productId: String
    let sharedSecret: String?
    
    /// SRVPurchaseValidationRequest
    ///
    /// - parameter productId: The product id of the purchase to validate.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    public init(productId: String, sharedSecret: String?) {
        self.productId = productId
        self.sharedSecret = sharedSecret
    }
}
