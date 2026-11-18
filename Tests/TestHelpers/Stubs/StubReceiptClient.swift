import Foundation
@testable import SwiftyReceiptValidator

final class StubReceiptClient: @unchecked Sendable {
    struct Stub {
        var validationError: Error?
        var validationResponse: SRVReceiptResponse = .mock()
    }
    
    var stub = Stub()
}

extension StubReceiptClient: ReceiptClient {
    func perform(_ request: ReceiptClientRequest) async throws -> SRVReceiptResponse {
        if let error = stub.validationError { throw error }
        return stub.validationResponse
    }
}
