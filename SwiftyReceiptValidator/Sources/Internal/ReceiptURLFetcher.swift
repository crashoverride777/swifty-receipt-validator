//
//  ReceiptURLFetcher.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import StoreKit

typealias ReceiptURLFetcherCompletion = (Result<URL, Error>) -> Void
typealias ReceiptURLFetcherRefreshRequest = SKReceiptRefreshRequest

protocol ReceiptURLFetcherType {
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequest?, handler: @escaping ReceiptURLFetcherCompletion)
}

final class ReceiptURLFetcher: NSObject {
    
    // MARK: Types
    
    enum FetchError: LocalizedError {
        case noReceiptFound
        
        public var errorDescription: String? {
            switch self {
            case .noReceiptFound:
                return LocalizedString.Error.ReceiptURLFetcher.noReceiptOnDevice
            }
        }
    }

    // MARK: - Properties

    private let appStoreReceiptURL: () -> URL?
    private let fileManager: FileManager
    private var completionHandler: ReceiptURLFetcherCompletion?
    private var receiptRefreshRequest: ReceiptURLFetcherRefreshRequest?
    
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

// MARK: - ReceiptURLFetcherType

extension ReceiptURLFetcher: ReceiptURLFetcherType {
    
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequest?, handler: @escaping ReceiptURLFetcherCompletion) {
        completionHandler = handler
        
        defer {
            clean()
        }
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            if let refreshRequest = refreshRequest {
                receiptRefreshRequest = refreshRequest
                receiptRefreshRequest?.delegate = self
                receiptRefreshRequest?.start()
            } else {
                handler(.failure(FetchError.noReceiptFound))
            }
            return
        }
        
        handler(.success(appStoreReceiptURL))
    }
}

// MARK: - SKRequestDelegate

extension ReceiptURLFetcher: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            completionHandler?(.failure(FetchError.noReceiptFound))
            return
        }
        
        completionHandler?(.success(appStoreReceiptURL))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        completionHandler?(.failure(error))
        clean()
    }
}

// MARK: - Private Methods

private extension ReceiptURLFetcher {
    
    func clean() {
        completionHandler = nil
        receiptRefreshRequest = nil
    }
}
