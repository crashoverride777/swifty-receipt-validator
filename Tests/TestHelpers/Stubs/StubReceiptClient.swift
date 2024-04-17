import Foundation
@testable import SwiftyReceiptValidator

final class StubReceiptClient {
    struct Stub {
        var validateResult: (_ url: URL, _ secret: String?, _ excludeOldTransactions: Bool) -> (Result<SRVReceiptResponse, Error>) = { (_, _, _) in
            .success(.mock())
        }
    }
    
    var stub = Stub()
}

extension StubReceiptClient: ReceiptClient {
    func perform(_ request: ReceiptClientRequest, completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
        let validationResult = stub.validateResult(request.receiptURL, request.sharedSecret, request.excludeOldTransactions)
        completion(validationResult)
    }
}
