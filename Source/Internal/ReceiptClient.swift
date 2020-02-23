//
//  ReceiptClient.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation

protocol ReceiptClientType {
    func perform(_ request: ReceiptClientRequest, handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
}

struct ReceiptClientRequest {
    let receiptURL: URL
    let sharedSecret: String?
    let excludeOldTransactions: Bool
}

final class ReceiptClient {
    
    // MARK: - Types
    
    struct Parameters: Encodable {
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
    
    private let sessionManager: URLSessionManagerType
    private let productionURL: String
    private let sandboxURL: String
    private let isLoggingEnabled: Bool
    
    // MARK: - Init
    
    init(sessionManager: URLSessionManagerType,
         productionURL: String,
         sandboxURL: String,
         isLoggingEnabled: Bool) {
        self.sessionManager = sessionManager
        self.productionURL = productionURL
        self.sandboxURL = sandboxURL
        self.isLoggingEnabled = isLoggingEnabled
    }
}

// MARK: - ReceiptClientType

extension ReceiptClient: ReceiptClientType {
    
    func perform(_ request: ReceiptClientRequest, handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        do {
            // Prepare url session parameters
            let receiptData = try Data(contentsOf: request.receiptURL)
            let parameters = Parameters(
                data: receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
                excludeOldTransactions: request.excludeOldTransactions,
                password: request.sharedSecret
            )

            // Start URL request to production server first, if status code returns test environment receipt, try sandbox.
            self.startSessionRequest(forURL: productionURL, parameters: parameters) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let receiptResponse):
                    switch receiptResponse.status {
                    case .testReceipt:
                        self.print("SRVReceiptClient production success with test receipt, trying sandbox mode...")
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
                    self.print("SRVReceiptClient session request success (PRODUCTION)")
                } else {
                    self.print("SRVReceiptClient session request success (SANDBOX)")
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
