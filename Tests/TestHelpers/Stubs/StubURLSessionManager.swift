import Foundation
@testable import SwiftyReceiptValidator

final class StubURLSessionManager {
    struct Stub {
        var error: Error?
        var urlStrings: [String] = []
        var responseData: Data = Data([1, 2, 3])
    }

    var stub = Stub()
}

extension StubURLSessionManager: URLSessionManager {
    func start<T: Encodable>(withURL urlString: String, parameters: T) async throws -> Data {
        if let error = stub.error { throw error }
        stub.urlStrings.append(urlString)
        return stub.responseData
    }
}
