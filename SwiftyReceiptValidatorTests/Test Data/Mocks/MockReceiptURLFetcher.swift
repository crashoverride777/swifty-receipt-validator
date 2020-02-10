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
        var fetchResult: (Result<URL, Error>) = .success(.test)
    }
    
    struct Mock {
        var refreshRequest: ReceiptURLFetcherRefreshRequestType? = nil
    }
    
    var stub = Stub()
    private(set) var mock = Mock()
}

extension MockReceiptURLFetcher: ReceiptURLFetcherType {
    
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequestType?,
               handler: @escaping ReceiptURLFetcherCompletion) {
        mock.refreshRequest = refreshRequest
        handler(stub.fetchResult)
    }
}
