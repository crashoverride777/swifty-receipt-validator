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

    private let appStoreReceiptURL: () -> URL?
    private let fileManager: FileManager
    
    private var receiptHandler: BundleReceiptFetcherHandler?
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    // MARK: - Computed Properties
    
    private var hasReceipt: Bool {
        guard let path = appStoreReceiptURL()?.path else {
            return false
        }
        
        return fileManager.fileExists(atPath: path)
    }
    
    // MARK: - Init
    
    init(appStoreReceiptURL: @escaping () -> URL?, fileManager: FileManager) {
        self.appStoreReceiptURL = appStoreReceiptURL
        self.fileManager = fileManager
    }
}

// MARK: - BundleReceiptFetcherType

extension BundleReceiptFetcher: BundleReceiptFetcherType {
    
    func fetch(requestRefreshIfNoneFound: Bool, handler: @escaping BundleReceiptFetcherHandler) {
        receiptHandler = handler
        
        defer {
            clean()
        }
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            if requestRefreshIfNoneFound {
                receiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
                receiptRefreshRequest?.delegate = self
                receiptRefreshRequest?.start()
            } else {
                handler(.failure(SRVError.noReceiptFound))
            }
            return
        }
        
        handler(.success(appStoreReceiptURL))
    }
}

// MARK: - SKRequestDelegate

extension BundleReceiptFetcher: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            receiptHandler?(.failure(SRVError.noReceiptFound))
            return
        }
        
        receiptHandler?(.success(appStoreReceiptURL))
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
