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
        var start: (urlString: String, parameters: Encodable)? = nil
    }
    
    var stub = Stub()
    private(set) var mock = Mock()
}

extension MockSessionManager: URLSessionManagerType {
    
    func start<T>(withURL urlString: String,
                  parameters: T,
                  handler: @escaping (Result<SRVReceiptResponse, Error>) -> Void) where T : Encodable {
        mock.start = (urlString: urlString, parameters: parameters)
        handler(stub.start)
    }
}
