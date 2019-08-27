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
        var start: (Result<SwiftyReceiptResponse, Error>) = .success(.fake(.subscription))
    }
    
    var stub = Stub()
}

extension MockSessionManager: URLSessionManagerType {
    
    func start(with urlString: String,
               parameters: [AnyHashable : Any],
               handler: @escaping (Result<SwiftyReceiptResponse, Error>) -> Void) {
        handler(stub.start)
    }
}
