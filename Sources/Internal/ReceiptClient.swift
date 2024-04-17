import Foundation

protocol ReceiptClient {
    func perform(_ request: ReceiptClientRequest, completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void)
}

struct ReceiptClientRequest {
    let receiptURL: URL
    let sharedSecret: String?
    let excludeOldTransactions: Bool
}

final class DefaultReceiptClient {
    
    // MARK: - Types
    
    struct Parameters: Encodable {
        let data: String
        let excludeOldTransactions: Bool
        let password: String?
        
        enum CodingKeys: String, CodingKey {
            case data = "receipt-data"
            case excludeOldTransactions = "exclude-old-transactions"
            case password
        }
    }
    
    // MARK: - Properties
    
    private let sessionManager: URLSessionManager
    private let productionURL: String
    private let sandboxURL: String
    private let isLoggingEnabled: Bool
    
    // MARK: - Initialization
    
    init(sessionManager: URLSessionManager,
         productionURL: String,
         sandboxURL: String,
         isLoggingEnabled: Bool) {
        self.sessionManager = sessionManager
        self.productionURL = productionURL
        self.sandboxURL = sandboxURL
        self.isLoggingEnabled = isLoggingEnabled
    }
}

// MARK: - ReceiptClient

extension DefaultReceiptClient: ReceiptClient {
    func perform(_ request: ReceiptClientRequest, completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
        do {
            // Prepare url session parameters
            let receiptData = try Data(contentsOf: request.receiptURL, options: .alwaysMapped)
            let parameters = Parameters(
                data: receiptData.base64EncodedString(options: []),
                excludeOldTransactions: request.excludeOldTransactions,
                password: request.sharedSecret
            )

            // Start URL request to production server first, if status code returns test environment receipt, try sandbox.
            startSessionRequest(forURL: productionURL, parameters: parameters) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let receiptResponse):
                    switch receiptResponse.status {
                    case .testReceipt:
                        self.print("SRVReceiptClient production success with test receipt, trying sandbox mode...")
                        self.startSessionRequest(forURL: self.sandboxURL, parameters: parameters, completion: completion)
                    default:
                        completion(.success(receiptResponse))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - Private Methods

private extension DefaultReceiptClient {
    func startSessionRequest(forURL urlString: String,
                             parameters: Parameters,
                             completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
        sessionManager.start(withURL: urlString, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                if urlString == self.productionURL {
                    self.print("SRVReceiptClient session request success (PRODUCTION)")
                } else {
                    self.print("SRVReceiptClient session request success (SANDBOX)")
                }
                
                do {
                    let decoder: JSONDecoder = .receiptResponse
                    let receiptResponse = try decoder.decode(SRVReceiptResponse.self, from: data)
                    completion(.success(receiptResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func print(_ items: Any...) {
        guard isLoggingEnabled else { return }
        Swift.print(items[0])
    }
}
