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
        var validateResult: (_ url: URL, _ secret: String?, _ excludeOldTransactions: Bool) -> (Result<SRVReceiptResponse, SRVError>) = { (_, _, _) in
            .success(.mock())
        }
    }
    
    var stub = Stub()
}

extension MockReceiptClient: ReceiptClientType {
    
    func fetch(with receiptURL: URL,
                  sharedSecret: String?,
                  excludeOldTransactions: Bool,
                  handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        let completion = stub.validateResult(receiptURL, sharedSecret, excludeOldTransactions)
        handler(completion)
    }
}
