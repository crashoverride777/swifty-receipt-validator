import Foundation
@testable import SwiftyReceiptValidator

final class MockResponseValidator {
    struct Stub {
        var validatePurchaseResult: (_ id: String, _ response: SRVReceiptResponse) -> (Result<SRVReceiptResponse, SRVError>) = { (_, _) in
            .success(.mock())
        }
        var validateSubscriptionResult: (_ response: SRVReceiptResponse, _ now: Date) -> (Result<SRVSubscriptionValidationResponse, SRVError>) = { (_, _) in
            .success(.mock())
        }
    }
    
    var stub = Stub()
}

extension MockResponseValidator: ResponseValidatorType {
    
    func validatePurchase(in response: SRVReceiptResponse,
                          productId: String,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        let completion = stub.validatePurchaseResult(productId, response)
        handler(completion)
    }
    
    func validateSubscriptions(in response: SRVReceiptResponse,
                               now: Date,
                               handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void) {
        let completion = stub.validateSubscriptionResult(response, now)
        handler(completion)
    }
}
