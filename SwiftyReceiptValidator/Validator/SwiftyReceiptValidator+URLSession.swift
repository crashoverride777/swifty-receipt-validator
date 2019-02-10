//
//  SwiftyReceiptValidator+URLSession.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

extension SwiftyReceiptValidator {
    
    func startURLSession(with receiptData: Data,
						   excludeOldTransactions: Bool,
                           sharedSecret: String?,
                           validationMode: ValidationMode,
                           handler: @escaping ResultHandler) {
        // Prepare receipt base 64 string
        let receiptBase64String = receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        // Prepare url session parameters
		var parameters: [String: Any] = ["receipt-data": receiptBase64String]
		parameters["exclude-old-transactions"] = excludeOldTransactions
        if let sharedSecret = sharedSecret {
            parameters["password"] = sharedSecret
        }
		
        
        // Start URL request to production server first, if status code returns test environment receipt, try sandbox.
        // This handles validation directily with apple. This is not the recommended way by apple as it is not secure.
        // It is still better than not doing any validation at all.
        sessionManager.start(with: .production, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let data):
                print("SwiftyReceiptValidator success (PRODUCTION)")
                do {
                    let response = try self.jsonDecoder.decode(SwiftyReceiptResponse.self, from: data)
                    if response.status == .testReceipt {
                        print("SwiftyReceiptValidator production mode with a Sandbox receipt, trying sandbox mode...")
                        self.startSandboxRequest(parameters: parameters, validationMode: validationMode, handler: handler)
                    } else {
                        self.validate(response, validationMode: validationMode, handler: handler)
                    }
                } catch {
                    handler(.failure(.other(error.localizedDescription), code: nil))
                }
                
            case .failure(let error):
                handler(.failure(.other(error.localizedDescription), code: nil))
            }
        }
    }
}

// MARK: - Sandbox Request

private extension SwiftyReceiptValidator {
    
    func startSandboxRequest(parameters: [AnyHashable: Any],
                             validationMode: ValidationMode,
                             handler: @escaping ResultHandler) {
        sessionManager.start(with: .sandbox, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let response = try self.jsonDecoder.decode(SwiftyReceiptResponse.self, from: data)
                    self.validate(response, validationMode: validationMode, handler: handler)
                } catch {
					print("Validation error: \(error)")
                    handler(.failure(.other(error.localizedDescription), code: nil))
                }
            case .failure(let error):
                handler(.failure(.other(error.localizedDescription), code: nil))
            }
        }
    }
}
