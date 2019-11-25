//
//  BundleReceiptFetcher.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import StoreKit

typealias BundleReceiptFetcherHandler = (Result<URL, Error>) -> Void

protocol BundleReceiptFetcherType {
    func fetch(requestRefreshIfNoneFound: Bool, handler: @escaping BundleReceiptFetcherHandler)
}

final class BundleReceiptFetcher: NSObject {
    
    // MARK: - Properties

    private var receiptHandler: BundleReceiptFetcherHandler?
    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: path)
    }
}

// MARK: - BundleReceiptFetcherType

extension BundleReceiptFetcher: BundleReceiptFetcherType {
    
    func fetch(requestRefreshIfNoneFound: Bool, handler: @escaping BundleReceiptFetcherHandler) {
        receiptHandler = handler
        
        defer {
            clean()
        }
        
        guard hasReceipt, let receiptURL = receiptURL else {
            if requestRefreshIfNoneFound {
                receiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
                receiptRefreshRequest?.delegate = self
                receiptRefreshRequest?.start()
            } else {
                handler(.failure(SRVError.noReceiptFound))
            }
            return
        }
        
        handler(.success(receiptURL))
    }
}

// MARK: - SKRequestDelegate

extension BundleReceiptFetcher: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptHandler?(.failure(SRVError.noReceiptFound))
            return
        }
        
        receiptHandler?(.success(receiptURL))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        receiptHandler?(.failure(error))
        clean()
    }
}

// MARK: - Private Methods

private extension BundleReceiptFetcher {
    
    func clean() {
        receiptHandler = nil
        receiptRefreshRequest = nil
    }
}
