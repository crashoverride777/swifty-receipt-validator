import Foundation
import StoreKit

protocol ReceiptURLFetcher: Sendable {
    func fetch(refreshRequest: SKReceiptRefreshRequest?) async throws -> URL
}

final class DefaultReceiptURLFetcher: NSObject, @unchecked Sendable {
    
    // MARK: - Types
    
    fileprivate typealias ReceiptURLFetcherCompletion = (Result<URL, SRVError>) -> Void
    
    // MARK: - Properties

    private let appStoreReceiptURL: () -> URL?
    private let fileManager: FileManager
    private var completionHandler: ReceiptURLFetcherCompletion?
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    // MARK: - Computed Properties
    
    private var hasReceipt: Bool {
        guard let path = appStoreReceiptURL()?.path else { return false }
        return fileManager.fileExists(atPath: path)
    }
    
    // MARK: - Initialization
    
    init(appStoreReceiptURL: @escaping () -> URL?, fileManager: FileManager) {
        self.appStoreReceiptURL = appStoreReceiptURL
        self.fileManager = fileManager
    }
}

// MARK: - ReceiptURLFetcher

extension DefaultReceiptURLFetcher: ReceiptURLFetcher {
    func fetch(refreshRequest: SKReceiptRefreshRequest?) async throws -> URL {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.fetch(refreshRequest: refreshRequest) {
                continuation.resume(with: $0)
            }
        }
    }
}

// MARK: - SKRequestDelegate

extension DefaultReceiptURLFetcher: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            completionHandler?(.failure(.noReceiptFoundInBundle))
            return
        }
        
        completionHandler?(.success(appStoreReceiptURL))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        completionHandler?(.failure(.other(error)))
        clean()
    }
}

// MARK: - Private Methods

private extension DefaultReceiptURLFetcher {
    func fetch(refreshRequest: SKReceiptRefreshRequest?, completion: @escaping (Result<URL, SRVError>) -> Void) {
        completionHandler = completion
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            if let refreshRequest = refreshRequest {
                receiptRefreshRequest = refreshRequest
                receiptRefreshRequest?.delegate = self
                receiptRefreshRequest?.start()
            } else {
                clean()
                completion(.failure(.noReceiptFoundInBundle))
            }
            return
        }
        
        clean()
        completion(.success(appStoreReceiptURL))
    }
    
    func clean() {
        completionHandler = nil
        receiptRefreshRequest = nil
    }
}
