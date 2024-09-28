import Foundation
import Testing
@testable import SwiftyReceiptValidator

final class ReceiptClientTests {
    
    // MARK: - Properties

    private var sessionManager: StubURLSessionManager!
    private let productionURL = "production.com"
    private let sandboxURL = "sandbox.com"

    // MARK: - Life Cycle
       
    init() {
        sessionManager = StubURLSessionManager()
    }

    deinit {
        sessionManager = nil
    }
    
    // MARK: - Tests
    
    // MARK: Fetch
  
    @Test func fetch_whenSuccess_returnsCorrectResponse() async throws {
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.subscription)
        let expectedResponse: SRVReceiptResponse = .mock(from: expectedDictionaryResponse)
        sessionManager.stub.responseData = expectedDictionaryResponse.asData
        let request = ReceiptClientRequest(receiptURL: .test, sharedSecret: "secret", excludeOldTransactions: false)
        let sut = makeSUT()
        let response = try await sut.perform(request)
        #expect(response == expectedResponse)
    }
    
    @Test func fetch_whenNoDownloadID_returnsCorrectResponse() async throws {
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.noDownloadID)
        let expectedResponse: SRVReceiptResponse = .mock(from: expectedDictionaryResponse)
        sessionManager.stub.responseData = expectedDictionaryResponse.asData
        let request = ReceiptClientRequest(receiptURL: .test, sharedSecret: "secret", excludeOldTransactions: false)
        let sut = makeSUT()
        let response = try await sut.perform(request)
        #expect(response == expectedResponse)
    }
    
    @Test func fetch_whenProductionReceipt_callsProductionURLOnly() async throws {
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.subscription)
        sessionManager.stub.responseData = expectedDictionaryResponse.asData
        let request = ReceiptClientRequest(receiptURL: .test, sharedSecret: "secret", excludeOldTransactions: false)
        let sut = makeSUT()
        _ = try await sut.perform(request)
        #expect(sessionManager.stub.urlStrings == [productionURL])
    }
    
    @Test func fetch_whenTestReceipt_callsProductionURL_thenSandboxURL() async throws {
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.sandbox)
        sessionManager.stub.responseData = expectedDictionaryResponse.asData
        let request = ReceiptClientRequest(receiptURL: .test, sharedSecret: "secret", excludeOldTransactions: false)
        let sut = makeSUT()
        _ = try await sut.perform(request)
        #expect(sessionManager.stub.urlStrings == [productionURL, sandboxURL])
    }
    
    @Test func fetch_whenConnectionError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        sessionManager.stub.error = expectedError
        let request = ReceiptClientRequest(receiptURL: .test, sharedSecret: "secret", excludeOldTransactions: false)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.perform(request)
        }
    }
    
    @Test func fetch_whenInvalidResponse_returnsCorrectError() async {
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.invalid)
        sessionManager.stub.responseData = expectedDictionaryResponse.asData
        let request = ReceiptClientRequest(receiptURL: .test, sharedSecret: "secret", excludeOldTransactions: false)
        let sut = makeSUT()
        await #expect(throws: DecodingError.self) {
            try await sut.perform(request)
        }
    }
}

// MARK: - Private Methods

private extension ReceiptClientTests {
    func makeSUT() -> ReceiptClient {
        DefaultReceiptClient(
            sessionManager: sessionManager,
            productionURL: "production.com",
            sandboxURL: "sandbox.com",
            isLoggingEnabled: false
        )
    }
}

// MARK: - Private Extensions

private extension Dictionary {
    var asData: Data {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            Issue.record("Could not encode codable to data")
            return Data()
        }
    }
}

private extension Encodable {
    var asData: Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            Issue.record("Could not encode codable to data")
            return Data()
        }
    }
}
