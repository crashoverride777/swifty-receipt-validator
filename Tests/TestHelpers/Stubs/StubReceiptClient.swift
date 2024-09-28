import Foundation
@testable import SwiftyReceiptValidator

final class StubReceiptClient {
    struct Stub {
        var error: Error?
        var requests: [ReceiptClientRequest] = []
        var response: SRVReceiptResponse = .mock()
    }
    
    var stub = Stub()
}

extension StubReceiptClient: ReceiptClient {
    func perform(_ request: ReceiptClientRequest) async throws -> SRVReceiptResponse {
        if let error = stub.error { throw error }
        stub.requests.append(request)
        return stub.response
    }
}
