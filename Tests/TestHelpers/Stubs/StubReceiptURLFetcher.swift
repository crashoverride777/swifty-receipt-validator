import Foundation
@testable import SwiftyReceiptValidator

final class StubReceiptURLFetcher {
    struct Stub {
        var refreshRequests: [ReceiptURLFetcherRefreshRequest] = []
        var fetchResult: (ReceiptURLFetcherRefreshRequest?) -> (Result<URL, Error>) = { _ in .success(.test) }
    }
    
    var stub = Stub()
}

extension StubReceiptURLFetcher: ReceiptURLFetcher {
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequest?, completion: @escaping ReceiptURLFetcherCompletion) {
        let fetchResult = stub.fetchResult(refreshRequest)
        completion(fetchResult)
    }
}
