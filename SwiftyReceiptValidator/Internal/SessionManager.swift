//
//  SessionManager.swift
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
