//
//  MockSessionManager.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

final class MockSessionManager {
    struct Stub {
        var start: (Result<SRVReceiptResponse, Error>) = .success(.mock())
    }
    
    struct Mock {
        var start: (urlString: String, parameters: [AnyHashable : Any])? = nil
    }
    
    var stub = Stub()
    private(set) var mock = Mock()
}

extension MockSessionManager: URLSessionManagerType {
    
    func start(with urlString: String,
               parameters: [AnyHashable : Any],
               handler: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
        mock.start = (urlString: urlString, parameters: parameters)
        handler(stub.start)
    }
}
