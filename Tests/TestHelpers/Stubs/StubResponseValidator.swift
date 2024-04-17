import Foundation
@testable import SwiftyReceiptValidator

final class StubResponseValidator {
    struct Stub {
        var validatePurchaseResult: (_ id: String, _ response: SRVReceiptResponse) -> (Result<SRVReceiptResponse, Error>) = { (_, _) in
            .success(.mock())
        }
        var validateSubscriptionResult: (_ response: SRVReceiptResponse, _ now: Date) -> (Result<SRVSubscriptionValidationResponse, Error>) = { (_, _) in
            .success(.mock())
        }
    }
    
    var stub = Stub()
}

extension StubResponseValidator: ResponseValidator {
    func validatePurchase(in response: SRVReceiptResponse,
                          productId: String,
                          completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
        let validationResult = stub.validatePurchaseResult(productId, response)
        completion(validationResult)
    }
    
    func validateSubscriptions(in response: SRVReceiptResponse,
                               now: Date,
                               completion: @escaping (Result<SRVSubscriptionValidationResponse, Error>) -> Void) {
        let validationResult = stub.validateSubscriptionResult(response, now)
        completion(validationResult)
    }
}
