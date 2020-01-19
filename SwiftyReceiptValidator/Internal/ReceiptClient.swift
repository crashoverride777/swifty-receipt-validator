//
//  ReceiptClient.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation

protocol ReceiptClientType {
    func fetch(with receiptURL: URL,
               sharedSecret: String?,
               excludeOldTransactions: Bool,
               handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
}

final class ReceiptClient {
    
    // MARK: - Types
    
    fileprivate struct Parameters: Encodable {
        let data: String
        let excludeOldTransactions: Bool
        let password: String?
        
        enum CodingKeys: String, CodingKey {
            case data = "receipt-data"
            case excludeOldTransactions = "exclude-old-transactions"
            case password
        }
    }
    
    // MARK: - Properties
    
    private let productionURL: String
    private let sandboxURL: String
    private let sessionManager: URLSessionManagerType
    private let isLoggingEnabled: Bool
    
    // MARK: - Init
    
    init(productionURL: String,
         sandboxURL: String,
         sessionManager: URLSessionManagerType,
         isLoggingEnabled: Bool) {
        self.productionURL = productionURL
        self.sandboxURL = sandboxURL
        self.sessionManager = sessionManager
        self.isLoggingEnabled = isLoggingEnabled
    }
}

// MARK: - ReceiptClientType

extension ReceiptClient: ReceiptClientType {
    
    func fetch(with receiptURL: URL,
               sharedSecret: String?,
               excludeOldTransactions: Bool,
               handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        do {
            // Prepare url session parameters
            let receiptData = try Data(contentsOf: receiptURL)
            let parameters = Parameters(
                data: receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
                excludeOldTransactions: excludeOldTransactions,
                password: sharedSecret
            )

            // Start URL request to production server first, if status code returns test environment receipt, try sandbox.
            self.startSessionRequest(forURL: productionURL, parameters: parameters) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let receiptResponse):
                    switch receiptResponse.status {
                    case .testReceipt:
                        self.print("SwiftyReceiptValidator production mode with test receipt, trying sandbox mode...")
                        self.startSessionRequest(forURL: self.sandboxURL, parameters: parameters, handler: handler)
                    default:
                        handler(.success(receiptResponse))
                    }
                case .failure(let error):
                    handler(.failure(.other(error)))
                }
            }
        } catch {
            handler(.failure(.other(error)))
        }
    }
}

// MARK: - Private Methods

private extension ReceiptClient {
    
    func startSessionRequest(forURL urlString: String,
                             parameters: Parameters,
                             handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        sessionManager.start(withURL: urlString, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                if urlString == self.productionURL {
                    self.print("SwiftyReceiptValidator success (PRODUCTION)")
                } else {
                    self.print("SwiftyReceiptValidator success (SANDBOX)")
                }
                
                do {
                    let decoder: JSONDecoder = .receiptResponse
                    let receiptResponse = try decoder.decode(SRVReceiptResponse.self, from: data)
                    handler(.success(receiptResponse))
                } catch {
                    handler(.failure(.other(error)))
                }
            case .failure(let error):
                handler(.failure(.other(error)))
            }
        }
    }
    
    func print(_ items: Any...) {
        guard isLoggingEnabled else {
            return
        }
        Swift.print(items[0])
    }
}
