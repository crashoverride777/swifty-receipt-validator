//
//  MockReceiptClient.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

final class MockReceiptClient {
    struct Stub {
        var validateResult: (Result<SRVReceiptResponse, SRVError>) = .success(.mock())
    }
    
    var stub = Stub()
}

extension MockReceiptClient: ReceiptClientType {
    
    func fetch(with receiptURL: URL,
                  sharedSecret: String?,
                  excludeOldTransactions: Bool,
                  handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        
        handler(stub.validateResult)
    }
}
