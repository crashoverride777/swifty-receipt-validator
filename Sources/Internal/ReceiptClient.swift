import Foundation

protocol ReceiptClient: Sendable {
    func perform(_ request: ReceiptClientRequest) async throws -> SRVReceiptResponse
}

struct ReceiptClientRequest: Sendable {
    let receiptURL: URL
    let sharedSecret: String?
    let excludeOldTransactions: Bool
}

struct DefaultReceiptClient {
    
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
    func perform(_ request: ReceiptClientRequest) async throws -> SRVReceiptResponse {
        // Prepare url session parameters
        let receiptData = try Data(contentsOf: request.receiptURL, options: .alwaysMapped)
        let parameters = Parameters(
            data: receiptData.base64EncodedString(options: []),
            excludeOldTransactions: request.excludeOldTransactions,
            password: request.sharedSecret
        )

        // Start URL request to production server first, if status code returns test environment receipt, try sandbox.
        let receiptResponse = try await startSessionRequest(forURL: productionURL, parameters: parameters)
        switch receiptResponse.status {
        case .testReceipt:
            self.print("SRVReceiptClient production success with test receipt, trying sandbox mode...")
            return try await self.startSessionRequest(forURL: self.sandboxURL, parameters: parameters)
        default:
            return receiptResponse
        }
    }
}

// MARK: - Private Methods

private extension DefaultReceiptClient {
    func startSessionRequest(forURL urlString: String, parameters: Parameters) async throws -> SRVReceiptResponse {
        let data = try await sessionManager.start(withURL: urlString, parameters: parameters)
        if urlString == productionURL {
            self.print("SRVReceiptClient session request success (PRODUCTION)")
        } else {
            self.print("SRVReceiptClient session request success (SANDBOX)")
        }
        return try JSONDecoder.receiptResponse.decode(SRVReceiptResponse.self, from: data)
    }
    
    func print(_ items: Any...) {
        guard isLoggingEnabled else { return }
        Swift.print(items[0])
    }
}
