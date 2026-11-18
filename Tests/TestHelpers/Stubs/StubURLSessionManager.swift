import Foundation
@testable import SwiftyReceiptValidator

actor StubURLSessionManager {
    struct Stub {
        var startError: Error?
        var startResponse: Data = Data([1, 2, 3])
    }

    var stub = Stub()
}

extension StubURLSessionManager: URLSessionManager {
    func start<T: Encodable & Sendable>(withURL urlString: String, parameters: T) async throws -> Data {
        if let error = stub.startError { throw error }
        return stub.startResponse
    }
}
