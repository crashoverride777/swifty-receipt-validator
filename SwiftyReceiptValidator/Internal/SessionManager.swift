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
 
    enum HTTPMethod: String {
        case post = "POST"
    }
    
    enum SessionError: LocalizedError {
        case url
        case data
        case other(Error)
        
        var errorDescription: String? {
            switch self {
            case .url:
                return LocalizedString.Error.url
            case .data:
                return LocalizedString.Error.data
            case .other(let error):
                return error.localizedDescription
            }
        }
    }
    
    // MARK: - Properties
    
    private var urlSession: URLSession?
    private let sessionConfiguration: URLSessionConfiguration
    
    private(set) lazy var jsonDecoder: JSONDecoder = {
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
    
    // MARK: - Start
    
    func start(with urlString: String,
               parameters: [AnyHashable: Any],
               httpMethod: HTTPMethod = .post,
               handler: @escaping (Result<SwiftyReceiptResponse, SessionError>) -> Void) {
        // Create url
        guard let url = URL(string: urlString) else {
            handler(.failure(.url))
            return
        }
        
        // Setup url request
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
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
                handler(.failure(.other(error)))
                return
            }
            
            // Unwrap data
            guard let data = data else {
                handler(.failure(.data))
                return
            }
                        
            // Parse data
            do {
                let response = try self.jsonDecoder.decode(SwiftyReceiptResponse.self, from: data)
                handler(.success(response))
            } catch {
                print(error)
                handler(.failure(.other(error)))
            }
        }.resume()
    }
}
