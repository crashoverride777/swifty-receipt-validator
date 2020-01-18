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
    
    var stub = Stub()
}

extension MockSessionManager: URLSessionManagerType {
    
    func start(with urlString: String,
               parameters: [AnyHashable : Any],
               handler: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
        handler(stub.start)
    }
}
