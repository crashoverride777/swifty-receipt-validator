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
        var start: (Result<Data, Error>) = .success(Data([1, 2, 3]))
    }
    
    struct Mock {
        var start: (urlString: String, parameters: Data)? = nil
    }
    
    var stub = Stub()
    private(set) var mock = Mock()
}

extension MockSessionManager: URLSessionManagerType {
    
    func start<T: Encodable>(withURL urlString: String,
                  parameters: T,
                  handler: @escaping (Result<Data, Error>) -> Void) {
        let parametersData = try! JSONEncoder().encode(parameters)
        mock.start = (urlString: urlString, parameters: parametersData)
        handler(stub.start)
    }
}
