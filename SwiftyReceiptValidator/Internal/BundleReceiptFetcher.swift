//
//  SRVBundleReceiptFetcher.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import StoreKit
import Combine

typealias SRVBundleReceiptFetcherHandler = (Result<URL, Error>) -> Void

protocol SRVBundleReceiptFetcherType {
    @available(iOS 13, *)
    func fetch(requestRefreshIfNoneFound: Bool) -> AnyPublisher<URL, Error>
    func fetch(requestRefreshIfNoneFound: Bool, handler: @escaping SRVBundleReceiptFetcherHandler)
}

final class SRVBundleReceiptFetcher: NSObject {
    
    // MARK: - Properties

    private var receiptHandler: SRVBundleReceiptFetcherHandler?
    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: path)
    }
}

// MARK: - SRVBundleReceiptFetcherType

extension SRVBundleReceiptFetcher: SRVBundleReceiptFetcherType {
    
    @available(iOS 13, *)
    func fetch(requestRefreshIfNoneFound: Bool) -> AnyPublisher<URL, Error> {
        return Future { [weak self] promise in
            self?.fetch(requestRefreshIfNoneFound: requestRefreshIfNoneFound) { result in
                switch result {
                case .success(let response):
                    promise(.success(response))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetch(requestRefreshIfNoneFound: Bool, handler: @escaping SRVBundleReceiptFetcherHandler) {
        receiptHandler = handler
        
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
        
        clean()
        handler(.success(receiptURL))
    }
}

// MARK: - SKRequestDelegate

extension SRVBundleReceiptFetcher: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptHandler?(.failure(SRVError.noReceiptFound))
            return
        }
        
        receiptHandler?(.success(receiptURL))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error)
        receiptHandler?(.failure(error))
        clean()
    }
}

// MARK: - Private Methods

private extension SRVBundleReceiptFetcher {
    
    func clean() {
        receiptHandler = nil
        receiptRefreshRequest = nil
    }
}
