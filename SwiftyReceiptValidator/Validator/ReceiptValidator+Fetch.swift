//
//  ReceiptValidator+Fetch.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
import StoreKit

extension SwiftyReceiptValidator {
    
    func fetchReceipt(sharedSecret: String?,
               refreshLocalReceiptIfNeeded: Bool,
               excludeOldTransactions: Bool,
               handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        let refreshRequest = refreshLocalReceiptIfNeeded ? SKReceiptRefreshRequest(receiptProperties: nil) : nil
        receiptURLFetcher.fetch(refreshRequest: refreshRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let receiptURL):
                self.receiptClient.fetch(
                    with: receiptURL,
                    sharedSecret: sharedSecret,
                    excludeOldTransactions: excludeOldTransactions,
                    handler: handler
                )
            case .failure(let error):
                self.print(error)
                handler(.failure(.other(error)))
            }
        }
    }
}
