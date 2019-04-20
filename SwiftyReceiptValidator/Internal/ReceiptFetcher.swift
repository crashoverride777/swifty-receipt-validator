//
//  ReceiptFetcher.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import StoreKit

final class SwiftyReceiptFetcher: NSObject {    
    typealias ReceiptHandler = (SwiftyReceiptValidatorResult<URL>) -> Void
    
    // MARK: - Properties
    
    private var receiptHandler: ReceiptHandler?
    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
    
    // MARK: - Methods
    
    func fetch(handler: @escaping ReceiptHandler) {
        receiptHandler = handler
        
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            receiptRefreshRequest?.delegate = self
            receiptRefreshRequest?.start()
            return
        }
        
        clean()
        handler(.success(receiptURL))
    }
    
    private func clean() {
        receiptHandler = nil
        receiptRefreshRequest = nil
    }
}

// MARK: - SKRequestDelegate

extension SwiftyReceiptFetcher: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptHandler?(.failure(.noReceiptFound, code: nil))
            return
        }
        
        receiptHandler?(.success(receiptURL))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error)
        receiptHandler?(.failure(.other(error), code: nil))
        clean()
    }
}
