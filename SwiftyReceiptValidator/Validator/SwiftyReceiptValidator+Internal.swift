//
//  SwiftyReceiptValidator+Internal.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

// MARK: - Start Receipt Validation

extension SwiftyReceiptValidator {

    private enum ParameterKey: String {
        case receiptData = "receipt-data"
        case password
    }
    
    func validateReceipt(with receiptData: Data,
                         sharedSecret: String?,
                         validationMode: ValidationMode,
                         handler: @escaping ResultHandler) {
        // Prepare receipt base 64 string
        let receiptBase64String = receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        // Prepare url session parameters
        var parameters = [ParameterKey.receiptData.rawValue: receiptBase64String]
        if let sharedSecret = sharedSecret {
            parameters[ParameterKey.password.rawValue] = sharedSecret
        }
        
        // Start URL request to production server first, if it fails because in test environment try sandbox otherwise fail completely.
        // This handles validation directily with apple. This is not the recommended way by apple as it is not secure.
        // It is still better than not doing any validation at all.
        startURLSession(with: .production, parameters: parameters, validationMode: validationMode) { result in
            switch result {
                
            case .success(let data):
                print("SwiftyReceiptValidator success (PRODUCTION)")
                handler(.success(data))
                
            case .failure(let error, let code):
                // Check if failed production request was due to a test receipt
                guard code == .testReceipt else {
                    handler(.failure(.other(error), code: code))
                    return
                }
                
                print("SwiftyReceiptValidator validation failed because we are in Production mode, trying sandbox mode...")
                
                // Handle sandbox request
                self.startURLSession(with: .sandbox, parameters: parameters, validationMode: validationMode) { result in
                    switch result {
                    case .success(let data):
                        print("SwiftyReceiptValidator success (SANDBOX)")
                        handler(.success(data))
                    case .failure(let error, let code):
                        handler(.failure(.other(error), code: code))
                    }
                }
            }
        }
    }
}

// MARK: - URL Session

extension SwiftyReceiptValidator {

    enum URLString: String {
        case sandbox    = "https://sandbox.itunes.apple.com/verifyReceipt"
        case production = "https://buy.itunes.apple.com/verifyReceipt"
    }
    
    func startURLSession(with urlString: URLString,
                         parameters: [AnyHashable: Any],
                         validationMode: ValidationMode,
                         handler: @escaping ResultHandler) {
        // Create url
        #if DEBUG
        let urlString: URLString = .sandbox
        #endif
        guard let url = URL(string: urlString.rawValue) else {
            handler(.failure(.url, code: nil))
            return
        }
        
        // Setup url request
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // Setup session
        let sessionConfiguration: URLSessionConfiguration = .default
        sessionConfiguration.timeoutIntervalForRequest = 20.0
        urlSession = URLSession(configuration: sessionConfiguration)
        
        // Start url session
        urlSession?.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            defer {
                self.urlSession = nil
            }
            
            // Check for error
            if let error = error {
                handler(.failure(.other(error), code: nil))
                return
            }
            
            // Unwrap data
            guard let data = data else {
                handler(.failure(.data, code: nil))
                return
            }
            
            // Parse json
            do {
                let response = try self.jsonDecoder.decode(SwiftyReceiptResponse.self, from: data)
                self.validate(response, validationMode: validationMode, handler: handler)
            } catch {
                handler(.failure(.other(error), code: nil))
                return
            }
        }.resume()
    }
}

// MARK: - Validation

extension SwiftyReceiptValidator {
    
    func validate(_ response: SwiftyReceiptResponse, validationMode: ValidationMode, handler: @escaping ResultHandler) {
        // Check receipt status is valid
        guard response.status == .valid else {
            handler(.failure(.invalidStatusCode, code: response.status))
            return
        }
        
        // Check receipt contains correct bundle id
        guard response.receipt.bundleId == Bundle.main.bundleIdentifier else {
            handler(.failure(.bundleIdNotMatching, code: response.status))
            return
        }
        
        // Run the validation for the correct mode
        switch validationMode {
        case .none:
            break
            
        case .product(let productId):
            // Check a valid receipt with matching product id was found
            guard response.receipt.inApp.first(where: { $0.productId == productId }) != nil else {
                handler(.failure(.productIdNotMatching, code: response.status))
                return
            }
            
        case .subscription:
            var receipts = response.latestReceipt?.inApp ?? response.receipt.inApp
            receipts.removeAll {
                guard let expiresDate = $0.expiresDate else { return true }
                return expiresDate < Date()
            }
            
            guard !receipts.isEmpty else {
                handler(.failure(.noValidSubscription, code: response.status))
                return
            }
        }
        
        // Return success handler
        handler(.success(response))
    }
}
