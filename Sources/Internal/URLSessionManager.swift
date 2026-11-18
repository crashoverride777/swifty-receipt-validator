import Foundation

protocol URLSessionManager: Sendable {
    func start<T: Encodable & Sendable>(withURL urlString: String, parameters: T) async throws -> Data
}

struct DefaultURLSessionManager {
    
    // MARK: - Types
    
    enum SessionError: Error {
        case url
        case parameterEncoding
    }
    
    // MARK: - Properties
    
    private let sessionConfiguration: URLSessionConfiguration
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    
    init(sessionConfiguration: URLSessionConfiguration, encoder: JSONEncoder) {
        self.sessionConfiguration = sessionConfiguration
        self.encoder = encoder
    }
}
    
// MARK: - URLSessionManager

extension DefaultURLSessionManager: URLSessionManager {  
    func start<T: Encodable & Sendable>(withURL urlString: String, parameters: T) async throws -> Data {
        guard let url = URL(string: urlString) else { throw SessionError.url }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try encoder.encode(parameters)
        let urlSession = URLSession(configuration: sessionConfiguration)
        let (data, _) = try await urlSession.data(for: urlRequest)
        return data
    }
}
