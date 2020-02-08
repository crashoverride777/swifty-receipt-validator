//
//  ReceiptURLFetcher.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import StoreKit

typealias ReceiptURLFetcherResultHandler = (Result<URL, Error>) -> Void

protocol ReceiptURLFetcherRefreshRequestType {
    var delegate: SKRequestDelegate? { get set }
    func cancel()
    func start()
}

protocol ReceiptURLFetcherType {
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequestType?, handler: @escaping ReceiptURLFetcherResultHandler)
}

extension SKReceiptRefreshRequest: ReceiptURLFetcherRefreshRequestType { }

final class ReceiptURLFetcher: NSObject {
    
    // MARK: - Properties

    private let appStoreReceiptURL: () -> URL?
    private let fileManager: FileManager
    
    private var receiptHandler: ReceiptURLFetcherResultHandler?
    private var receiptRefreshRequest: ReceiptURLFetcherRefreshRequestType?
    
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
    
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequestType?, handler: @escaping ReceiptURLFetcherResultHandler) {
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

extension ReceiptURLFetcher: SKRequestDelegate {
    
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

private extension ReceiptURLFetcher {
    
    func clean() {
        receiptHandler = nil
        receiptRefreshRequest = nil
    }
}
