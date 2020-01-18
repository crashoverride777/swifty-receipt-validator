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
        var refreshRequest: BundleReceiptFetcherReceiptRefreshRequestType? = nil
    }
    
    var stub = Stub()
    private(set) var mock = Mock()
}

extension MockReceiptFetcher: BundleReceiptFetcherType {
    
    func fetch(refreshRequest: BundleReceiptFetcherReceiptRefreshRequestType?,
               handler: @escaping BundleReceiptFetcherHandler) {
        mock.refreshRequest = refreshRequest
        handler(stub.fetchResult)
    }
}
