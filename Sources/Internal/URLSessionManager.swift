import Foundation

public protocol URLSessionManager: AnyObject {
    func start<T: Encodable>(withURL urlString: String, parameters: T) async throws -> Data
}

final class DefaultURLSessionManager {
    
    // MARK: - Types
    
    enum SessionError: Error {
        case url
        case invalidResponse
        case data
    }
    
    // MARK: - Properties
    
    private let urlSession: URLSession
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    
    init(sessionConfiguration: URLSessionConfiguration, encoder: JSONEncoder) {
        self.urlSession = URLSession(configuration: sessionConfiguration)
        self.encoder = encoder
    }
}
    
// MARK: - URLSessionManager

extension DefaultURLSessionManager: URLSessionManager {
    func start<T: Encodable>(withURL urlString: String, parameters: T) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw SessionError.url
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try encoder.encode(parameters)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard response is HTTPURLResponse else {
            throw SessionError.invalidResponse
        }
        return data
    }
}
