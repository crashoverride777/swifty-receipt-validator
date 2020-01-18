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
        var fetchRequestRefreshIfNoneFound: Bool = false
    }
    
    var stub = Stub()
    private(set) var mock = Mock()
}

extension MockReceiptFetcher: BundleReceiptFetcherType {
   
    func fetch(requestRefreshIfNoneFound: Bool, handler: @escaping BundleReceiptFetcherHandler) {
        mock.fetchRequestRefreshIfNoneFound = requestRefreshIfNoneFound
        handler(stub.fetchResult)
    }
}
