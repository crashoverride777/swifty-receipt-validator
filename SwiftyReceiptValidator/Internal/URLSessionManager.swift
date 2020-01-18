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
                             handler: @escaping (Result<SRVReceiptResponse, Error>) -> Void)
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
    
    private var urlSession: URLSession?
    private let sessionConfiguration: URLSessionConfiguration
    
    private let encoder = JSONEncoder()
    private(set) lazy var decoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Init
    
    init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = sessionConfiguration
    }
}
    
// MARK: - URLSessionManagerType

extension URLSessionManager: URLSessionManagerType {
 
    func start<T: Encodable>(withURL urlString: String,
                             parameters: T,
                             handler: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
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
            
            // Parse data
            do {
                let response = try self.decoder.decode(SRVReceiptResponse.self, from: data)
                handler(.success(response))
            } catch {
                handler(.failure(error))
            }
        }.resume()
    }
}
