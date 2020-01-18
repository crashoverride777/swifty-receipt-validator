//
//  BundleReceiptFetcher.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import StoreKit

typealias ReceiptFetcherResultHandler = (Result<URL, Error>) -> Void

protocol ReceiptFetcherReceiptRefreshRequestType {
    var delegate: SKRequestDelegate? { get set }
    func cancel()
    func start()
}

protocol ReceiptFetcherType {
    func fetch(refreshRequest: ReceiptFetcherReceiptRefreshRequestType?, handler: @escaping ReceiptFetcherResultHandler)
}

extension SKReceiptRefreshRequest: ReceiptFetcherReceiptRefreshRequestType { }

final class ReceiptFetcher: NSObject {
    
    // MARK: - Properties

    private let appStoreReceiptURL: () -> URL?
    private let fileManager: FileManager
    
    private var receiptHandler: ReceiptFetcherResultHandler?
    private var receiptRefreshRequest: ReceiptFetcherReceiptRefreshRequestType?
    
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

// MARK: - ReceiptFetcherType

extension ReceiptFetcher: ReceiptFetcherType {
    
    func fetch(refreshRequest: ReceiptFetcherReceiptRefreshRequestType?, handler: @escaping ReceiptFetcherResultHandler) {
        receiptHandler = handler
        
        defer {
            clean()
        }
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            if let refreshRequest = refreshRequest {
                receiptRefreshRequest = refreshRequest
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

extension ReceiptFetcher: SKRequestDelegate {
    
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

private extension ReceiptFetcher {
    
    func clean() {
        receiptHandler = nil
        receiptRefreshRequest = nil
    }
}
