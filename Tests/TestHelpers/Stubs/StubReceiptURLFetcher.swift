import Foundation
import StoreKit
@testable import SwiftyReceiptValidator

final class StubReceiptURLFetcher: @unchecked Sendable {
    struct Stub {
        var refreshRequests: [SKReceiptRefreshRequest] = []
        var fetchError: Error?
        var fetchURL: URL = URL(string: "example.com")!
    }
    
    var stub = Stub()
}

extension StubReceiptURLFetcher: ReceiptURLFetcher {
    func fetch(refreshRequest: SKReceiptRefreshRequest?, completion: @escaping (Result<URL, Error>) -> Void) {
        if let error = stub.fetchError {
            completion(.failure(error))
            return
        }
        completion(.success(stub.fetchURL))
    }
}
