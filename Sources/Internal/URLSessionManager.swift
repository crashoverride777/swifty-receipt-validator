import Foundation

public protocol URLSessionManager: AnyObject {
    func start<T: Encodable>(withURL urlString: String, parameters: T, completion: @escaping (Result<Data, Error>) -> Void)
}

final class DefaultURLSessionManager {
    
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
    
// MARK: - URLSessionManager

extension DefaultURLSessionManager: URLSessionManager {
    func start<T: Encodable>(withURL urlString: String, parameters: T, completion: @escaping (Result<Data, Error>) -> Void) {
        // Create url
        guard let url = URL(string: urlString) else {
            completion(.failure(SessionError.url))
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
            completion(.failure(SessionError.parameterEncoding))
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
                completion(.failure(error))
                return
            }
            
            // Unwrap data
            guard let data = data else {
                completion(.failure(SessionError.data))
                return
            }
            
            // Return success handler with data
            completion(.success(data))
        }
        .resume()
    }
}
