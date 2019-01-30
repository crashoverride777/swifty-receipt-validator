//
//  SessionManager.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

final class SessionManager {
    
    // MARK: - Types
    
    enum URLString: String {
        case sandbox    = "https://sandbox.itunes.apple.com/verifyReceipt"
        case production = "https://buy.itunes.apple.com/verifyReceipt"
    }
    
    enum HTTPMethod: String {
        case post = "POST"
    }
    
    enum Result {
        case success(Data)
        case failure(SessionError)
    }
    
    enum SessionError: Error {
        case url
        case data
        case other(String)
        
        public var localizedDescription: String {
            switch self {
            case .url:
                return "SwiftyReceiptValidator session URL error"
            case .data:
                return "SwiftyReceiptValidator session data error"
            case .other(let message):
                return message
            }
        }
    }
    
    // MARK: - Properties
    
    private var urlSession: URLSession?
    
    // MARK: - Start
    
    func start(with urlString: URLString,
               parameters: [AnyHashable: Any],
               handler: @escaping (Result) -> Void) {
        // Create url
        guard let url = URL(string: urlString.rawValue) else {
            handler(.failure(.url))
            return
        }
        
        // Setup url request
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = HTTPMethod.post.rawValue
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
                handler(.failure(.other(error.localizedDescription)))
                return
            }
            
            // Unwrap data
            guard let data = data else {
                handler(.failure(.data))
                return
            }
            
            // Return data
            handler(.success(data))
        }.resume()
    }
}
