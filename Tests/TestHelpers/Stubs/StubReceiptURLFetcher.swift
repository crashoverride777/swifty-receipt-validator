import Foundation
import StoreKit
@testable import SwiftyReceiptValidator

final class StubReceiptURLFetcher: @unchecked Sendable {
    struct Stub {
        var fetchError: Error?
        var fetchResponse: URL = .test
    }
    
    var stub = Stub()
}

extension StubReceiptURLFetcher: ReceiptURLFetcher {
    func fetch(refreshRequest: SKReceiptRefreshRequest?) async throws -> URL {
        if let error = stub.fetchError { throw error }
        return stub.fetchResponse
    }
}
