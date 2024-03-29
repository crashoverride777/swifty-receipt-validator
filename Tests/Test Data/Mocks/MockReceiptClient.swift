import Foundation
@testable import SwiftyReceiptValidator

final class MockReceiptClient {
    struct Stub {
        var validateResult: (_ url: URL, _ secret: String?, _ excludeOldTransactions: Bool) -> (Result<SRVReceiptResponse, SRVError>) = { (_, _, _) in
            .success(.mock())
        }
    }
    
    var stub = Stub()
}

extension MockReceiptClient: ReceiptClientType {
    
    func perform(_ request: ReceiptClientRequest, handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        let completion = stub.validateResult(request.receiptURL, request.sharedSecret, request.excludeOldTransactions)
        handler(completion)
    }
}
