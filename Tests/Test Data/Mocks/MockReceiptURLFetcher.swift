import Foundation
@testable import SwiftyReceiptValidator

final class MockReceiptURLFetcher {
    struct Stub {
        var fetchResult: (ReceiptURLFetcherRefreshRequest?) -> (Result<URL, SRVError>) = { _ in .success(.test) }
    }
    
    var stub = Stub()
}

extension MockReceiptURLFetcher: ReceiptURLFetcherType {
    
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequest?, handler: @escaping ReceiptURLFetcherCompletion) {
        let completion = stub.fetchResult(refreshRequest)
        handler(completion)
    }
}
