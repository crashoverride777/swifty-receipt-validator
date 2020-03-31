//
//  MockReceiptURLFetcher.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

final class MockReceiptURLFetcher {
    struct Stub {
        var fetchResult: (ReceiptURLFetcherRefreshRequest?) -> (Result<URL, Error>) = { _ in .success(.test) }
    }
    
    var stub = Stub()
}

extension MockReceiptURLFetcher: ReceiptURLFetcherType {
    
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequest?, handler: @escaping ReceiptURLFetcherCompletion) {
        let completion = stub.fetchResult(refreshRequest)
        handler(completion)
    }
}
