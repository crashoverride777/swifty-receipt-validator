//
//  SwiftyReceiptValidator+URLSession.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2016-2019 Dominik Ringler
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

private enum ParamsKey: String {
    case data = "receipt-data"
    case excludeOldTransactions = "exclude-old-transactions"
    case password
}

extension SwiftyReceiptValidator {
    
    func startURLSession(with receiptData: Data,
                         sharedSecret: String?,
                         excludeOldTransactions: Bool,
                         handler: @escaping ResultHandler) {
        // Prepare receipt base 64 string
        let receiptBase64String = receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        // Prepare url session parameters
        var parameters: [String: Any] = [
            ParamsKey.data.rawValue: receiptBase64String,
            ParamsKey.excludeOldTransactions.rawValue: excludeOldTransactions
        ]
        
        if let sharedSecret = sharedSecret {
            parameters[ParamsKey.password.rawValue] = sharedSecret
        }
        
        // Start URL request to production server first, if status code returns test environment receipt, try sandbox.
        // This handles validation directily with apple. This is not the recommended way by apple as it is not secure.
        // It is still better than not doing any validation at all.
        sessionManager.start(with: configuration.productionURL, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                print("SwiftyReceiptValidator success (PRODUCTION)")
                if response.status == .testReceipt {
                    print("SwiftyReceiptValidator production mode with a Sandbox receipt, trying sandbox mode...")
                    self.startSandboxRequest(parameters: parameters, handler: handler)
                } else {
                    handler(.success(response))
                }                
            case .failure(let error):
                self.printError(error)
                handler(.failure(.other(error)))
            }
        }
    }
}

// MARK: - Sandbox Request

private extension SwiftyReceiptValidator {
    
    func startSandboxRequest(parameters: [AnyHashable: Any], handler: @escaping ResultHandler) {
        sessionManager.start(with: configuration.sandboxURL, parameters: parameters) { result in
            switch result {
            case .success(let response):
                print("SwiftyReceiptValidator success (SANDBOX)")
                handler(.success(response))
            case .failure(let error):
                self.printError(error)
                handler(.failure(.other(error)))
            }
        }
    }
}
