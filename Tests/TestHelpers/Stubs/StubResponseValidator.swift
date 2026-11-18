import Foundation
@testable import SwiftyReceiptValidator

final class StubResponseValidator: @unchecked Sendable {
    struct Stub {
        var validatePurchaseError: Error?
        var validatePurchaseResponse: SRVReceiptResponse = .mock()
        var validateSubscriptionError: Error?
        var validateSubscriptionResponse: SRVSubscriptionValidationResponse = .mock()
    }
    
    var stub = Stub()
}

extension StubResponseValidator: ResponseValidator {
    func validatePurchase(in response: SRVReceiptResponse, productId: String) async throws -> SRVReceiptResponse {
        if let error = stub.validatePurchaseError { throw error }
        return stub.validatePurchaseResponse
    }
    
    func validateSubscriptions(in response: SRVReceiptResponse, now: Date) async throws -> SRVSubscriptionValidationResponse {
        if let error = stub.validateSubscriptionError { throw error }
        return stub.validateSubscriptionResponse
    }
}
