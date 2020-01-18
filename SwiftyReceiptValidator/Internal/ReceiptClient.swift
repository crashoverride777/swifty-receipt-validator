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
    
    struct Parameters: Encodable {
        let data: String
        let excludeOldTransactions: Bool
        let password: String?
        
        enum CodingKeys: String, CodingKey {
            case data = "receipt-data"
            case excludeOldTransactions = "exclude-old-transactions"
            case password

        }
//        var parameters: [String: Any] = [
//            ParamsKey.data.rawValue: receiptBase64String,
//            ParamsKey.excludeOldTransactions.rawValue: excludeOldTransactions
//        ]
//
//        if let sharedSecret = sharedSecret {
//            parameters[ParamsKey.password.rawValue] = sharedSecret
//        }
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
            // Get receipt data
            let receiptData = try Data(contentsOf: receiptURL)
            
            // Prepare url session parameters
            let parameters = Parameters(
                data: receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
                excludeOldTransactions: excludeOldTransactions,
                password: sharedSecret
            )
            #warning("remove after tested new Parameters stuct")
//            var parameters: [String: Any] = [
//                ParamsKey.data.rawValue: receiptBase64String,
//                ParamsKey.excludeOldTransactions.rawValue: excludeOldTransactions
//            ]
//
//            if let sharedSecret = sharedSecret {
//                parameters[ParamsKey.password.rawValue] = sharedSecret
//            }
            
            // Start production url request
            self.startProductionRequest(with: parameters, handler: handler)
        } catch {
            handler(.failure(.other(error)))
        }
    }
}

// MARK: - Private Methods

private extension ReceiptClient {
    
    func startProductionRequest(with parameters: Parameters,
                                handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        // Start URL request to production server first, if status code returns test environment receipt, try sandbox.
        // This handles validation directily with apple. This is not the recommended way by apple as it is not secure.
        // It is still better than not doing any validation at all.
        sessionManager.start(withURL: productionURL, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.print("SwiftyReceiptValidator success (PRODUCTION) with response\(response)")
                if response.status == .testReceipt {
                    self.print("SwiftyReceiptValidator production mode with test receipt, trying sandbox mode...")
                    self.startSandboxRequest(with: parameters, handler: handler)
                } else {
                    handler(.success(response))
                }
            case .failure(let error):
                self.print(error)
                handler(.failure(.other(error)))
            }
        }
    }
    
    func startSandboxRequest(with parameters: Parameters,
                             handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        sessionManager.start(withURL: sandboxURL, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.print("SwiftyReceiptValidator success (SANDBOX) with response \(response)")
                handler(.success(response))
            case .failure(let error):
                self.print(error)
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
