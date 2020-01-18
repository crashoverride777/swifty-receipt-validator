//
//  MockReceiptFetcher.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

final class MockReceiptFetcher {
    struct Stub {
        var fetchResult: (Result<URL, Error>) = .success(.test)
    }
    
    struct Mock {
        var refreshRequest: ReceiptFetcherReceiptRefreshRequestType? = nil
    }
    
    var stub = Stub()
    private(set) var mock = Mock()
}

extension MockReceiptFetcher: ReceiptFetcherType {
    
    func fetch(refreshRequest: ReceiptFetcherReceiptRefreshRequestType?,
               handler: @escaping ReceiptFetcherResultHandler) {
        mock.refreshRequest = refreshRequest
        handler(stub.fetchResult)
    }
}
