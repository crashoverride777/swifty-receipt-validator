import Foundation
import StoreKit

protocol ReceiptURLFetcher: Sendable {
    func fetch(refreshRequest: SKReceiptRefreshRequest?, completion: @escaping (Result<URL, Error>) -> Void)
}

final class DefaultReceiptURLFetcher: NSObject, @unchecked Sendable {
    
    // MARK: - Properties

    private let appStoreReceiptURL: @Sendable () -> URL?
    private let fileManager: FileManager
    private var completionHandler: ((Result<URL, Error>) -> Void)?
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    // MARK: - Computed Properties
    
    private var hasReceipt: Bool {
        guard let path = appStoreReceiptURL()?.path else { return false }
        return fileManager.fileExists(atPath: path)
    }
    
    // MARK: - Initialization
    
    init(appStoreReceiptURL: @escaping @Sendable () -> URL?, fileManager: FileManager) {
        self.appStoreReceiptURL = appStoreReceiptURL
        self.fileManager = fileManager
    }
}

// MARK: - ReceiptURLFetcher

extension DefaultReceiptURLFetcher: ReceiptURLFetcher {
    func fetch(refreshRequest: SKReceiptRefreshRequest?, completion: @escaping (Result<URL, Error>) -> Void) {
        completionHandler = completion
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            if let refreshRequest = refreshRequest {
                receiptRefreshRequest = refreshRequest
                receiptRefreshRequest?.delegate = self
                receiptRefreshRequest?.start()
            } else {
                clean()
                completion(.failure(SRVError.noReceiptFoundInBundle))
            }
            return
        }
        
        clean()
        completion(.success(appStoreReceiptURL))
    }
}

// MARK: - SKRequestDelegate

extension DefaultReceiptURLFetcher: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            completionHandler?(.failure(SRVError.noReceiptFoundInBundle))
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

private extension DefaultReceiptURLFetcher {
    func clean() {
        completionHandler = nil
        receiptRefreshRequest = nil
    }
}
