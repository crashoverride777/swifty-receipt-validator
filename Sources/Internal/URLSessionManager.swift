//
//  URLSessionManager.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public protocol URLSessionManagerType: AnyObject {
    func start<T: Encodable>(
        withURL urlString: String,
        parameters: T,
        handler: @escaping (Result<Data, Error>) -> Void
    )
}

final class URLSessionManager {
    
    // MARK: - Types
    
    enum SessionError: Error {
        case url
        case parameterEncoding
        case data
    }
    
    // MARK: - Properties
    
    private let sessionConfiguration: URLSessionConfiguration
    private let encoder: JSONEncoder
    private var urlSession: URLSession?
    
    // MARK: - Initialization
    
    init(sessionConfiguration: URLSessionConfiguration, encoder: JSONEncoder) {
        self.sessionConfiguration = sessionConfiguration
        self.encoder = encoder
    }
}
    
// MARK: - URLSessionManagerType

extension URLSessionManager: URLSessionManagerType {
 
    func start<T: Encodable>(
        withURL urlString: String,
        parameters: T,
        handler: @escaping (Result<Data, Error>) -> Void
    ) {
        // Create url
        guard let url = URL(string: urlString) else {
            handler(.failure(SessionError.url))
            return
        }
        
        // Create url request
        var urlRequest = URLRequest(url: url)

        // Set url request cache policy to ignore cache data
        urlRequest.cachePolicy = .reloadIgnoringCacheData

        // Set url request http method to POST
        urlRequest.httpMethod = "POST"

        // Set url request parameters
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
