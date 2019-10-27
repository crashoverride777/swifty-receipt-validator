//
//  SRVURLSessionManager.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
import Combine

public protocol SRVURLSessionManagerType: AnyObject {
    @available(iOS 13, *)
    func start(with urlString: String, parameters: [AnyHashable: Any]) -> AnyPublisher<SRVReceiptResponse, Error>
    func start(with urlString: String,
               parameters: [AnyHashable: Any],
               handler: @escaping (Result<SRVReceiptResponse, Error>) -> Void)
}

final class SRVURLSessionManager {
    
    // MARK: - Types
    
    enum SessionError: LocalizedError {
        case url
        case data
        
        var errorDescription: String? {
            switch self {
            case .url:
                return SRVLocalizedString.Error.url
            case .data:
                return SRVLocalizedString.Error.data
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
}
    
// MARK: - SRVURLSessionManagerType

extension SRVURLSessionManager: SRVURLSessionManagerType {
    
    @available(iOS 13, *)
    func start(with urlString: String, parameters: [AnyHashable: Any]) -> AnyPublisher<SRVReceiptResponse, Error> {
        return Future { [weak self] promise in
            self?.start(with: urlString, parameters: parameters) { result in
                switch result {
                case .success(let response):
                    promise(.success(response))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func start(with urlString: String,
               parameters: [AnyHashable: Any],
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
                let response = try self.jsonDecoder.decode(SRVReceiptResponse.self, from: data)
                handler(.success(response))
            } catch {
                print(error)
                handler(.failure(error))
            }
        }.resume()
    }
}
