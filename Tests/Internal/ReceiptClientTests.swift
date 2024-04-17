import XCTest
@testable import SwiftyReceiptValidator

class ReceiptClientTests: XCTestCase {
    
    // MARK: - Properties

    private var sessionManager: StubURLSessionManager!
    private let productionURL = "production.com"
    private let sandboxURL = "sandbox.com"

    // MARK: - Life Cycle
       
    override func setUp() {
        super.setUp()
        sessionManager = StubURLSessionManager()
    }

    override func tearDown() {
        sessionManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    // MARK: Parameters
    
    func test_setsCorrectParameters() throws {
        let expectation = XCTestExpectation(description: "Finished")
        let receiptURL: URL = .test

        let receiptData = try Data(contentsOf: receiptURL)
        let expectedParameters = DefaultReceiptClient.Parameters(
            data: receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
            excludeOldTransactions: false,
            password: "secret"
        )
        
        sessionManager.stub.start = { (_, parameters) in
            XCTAssertEqual(parameters, expectedParameters.asData)
            expectation.fulfill()
            return .success(SRVReceiptResponse.mock(.subscription).asData) }
        
        let request = ReceiptClientRequest(
            receiptURL: receiptURL,
            sharedSecret: expectedParameters.password,
            excludeOldTransactions: expectedParameters.excludeOldTransactions
        )
        
        let sut = makeSUT()
        sut.perform(request) { _ in }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    // MARK: Fetch
  
    func test_fetch_success_returnsCorrectResponse() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.subscription)
        let expectedResponse: SRVReceiptResponse = .mock(from: expectedDictionaryResponse)
        sessionManager.stub.start = { (_, _) in .success(expectedDictionaryResponse.asData) }
        
        let request = ReceiptClientRequest(
            receiptURL: .test,
            sharedSecret: "secret",
            excludeOldTransactions: false
        )
        
        let sut = makeSUT()
        sut.perform(request) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedResponse)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_success_whenNoDownloadID_returnsCorrectResponse() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.noDownloadID)
        let expectedResponse: SRVReceiptResponse = .mock(from: expectedDictionaryResponse)
        sessionManager.stub.start = { (_, _) in .success(expectedDictionaryResponse.asData) }
        
        let request = ReceiptClientRequest(
            receiptURL: .test,
            sharedSecret: "secret",
            excludeOldTransactions: false
        )
        
        let sut = makeSUT()
        sut.perform(request) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedResponse)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_success_whenProductionReceipt_callsProductionURL() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.subscription)
        
        sessionManager.stub.start = { (url, _) in
            XCTAssertEqual(url, self.productionURL)
            expectation.fulfill()
            return .success(expectedDictionaryResponse.asData)
        }
        
        let request = ReceiptClientRequest(
            receiptURL: .test,
            sharedSecret: "secret",
            excludeOldTransactions: false
        )
        
        let sut = makeSUT()
        sut.perform(request) { _ in }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_success_whenTestReceipt_callsProductionURL_thenSandboxURL() {
        let expectation = XCTestExpectation(description: "Finished")
        expectation.expectedFulfillmentCount = 2
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.sandbox)
        
        var count = 0
        sessionManager.stub.start = { (url, _) in
            XCTAssertEqual(url, count == 0 ? self.productionURL : self.sandboxURL)
            count += 1
            expectation.fulfill()
            return .success(expectedDictionaryResponse.asData)
        }
        
        let request = ReceiptClientRequest(
            receiptURL: .test,
            sharedSecret: "secret",
            excludeOldTransactions: false
        )
        
        let sut = makeSUT()
        sut.perform(request) { _ in }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_failure_whenConnectionError_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        sessionManager.stub.start = { (_, _) in .failure(expectedError) }
        
        let request = ReceiptClientRequest(
            receiptURL: .test,
            sharedSecret: "secret",
            excludeOldTransactions: false
        )
        
        let sut = makeSUT()
        sut.perform(request) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_failure_whenInvalidResponse_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.invalid)
        sessionManager.stub.start = { (_, _) in .success(expectedDictionaryResponse.asData) }
        
        let request = ReceiptClientRequest(
            receiptURL: .test,
            sharedSecret: "secret",
            excludeOldTransactions: false
        )
        
        let sut = makeSUT()
        sut.perform(request) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it is missing.")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
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
            XCTFail("Could not encode codable to data")
            return Data()
        }
    }
}

private extension Encodable {
    var asData: Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            XCTFail("Could not encode codable to data")
            return Data()
        }
    }
}
