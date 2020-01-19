//
//  URLSessionManager.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public protocol URLSessionManagerType: AnyObject {
    func start<T: Encodable>(withURL urlString: String,
                             parameters: T,
                             handler: @escaping (Result<Data, Error>) -> Void)
}

final class URLSessionManager {
    
    // MARK: - Types
    
    enum SessionError: LocalizedError {
        case url
        case parameterEncoding
        case data
        
        var errorDescription: String? {
            switch self {
            case .url:
                return LocalizedString.Error.url
            case .parameterEncoding:
                return LocalizedString.Error.parameterEncoding
            case .data:
                return LocalizedString.Error.data
            }
        }
    }
    
    // MARK: - Properties
    
    private let sessionConfiguration: URLSessionConfiguration
    private let encoder: JSONEncoder
    private var urlSession: URLSession?
    
    // MARK: - Init
    
    init(sessionConfiguration: URLSessionConfiguration = .default,
         encoder: JSONEncoder = JSONEncoder()) {
        self.sessionConfiguration = sessionConfiguration
        self.encoder = encoder
    }
}
    
// MARK: - URLSessionManagerType

extension URLSessionManager: URLSessionManagerType {
 
    func start<T: Encodable>(withURL urlString: String,
                             parameters: T,
                             handler: @escaping (Result<Data, Error>) -> Void) {
        // Create url
        guard let url = URL(string: urlString) else {
            handler(.failure(SessionError.url))
            return
        }
        
        // Setup url request
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = "POST"
        do {
            urlRequest.httpBody = try encoder.encode(parameters)
        } catch {
            handler(.failure(SessionError.parameterEncoding))
        }
        
        // Setup url session
        urlSession = URLSession(configuration: sessionConfiguration)
        
        // Start data task
        urlSession?.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            defer {
                self.urlSession = nil
            }
            
            // Check for error
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Unwrap data
            guard let data = data else {
                handler(.failure(SessionError.data))
                return
            }
            // Return success handler with data
            handler(.success(data))
        }
        .resume()
    }
}
