//
//  ReceiptClientTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class ReceiptClientTests: XCTestCase {
    
    // MARK: - Types
    
    fileprivate struct Parameters: Encodable {
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

    private var sessionManager: MockSessionManager!
    
    // MARK: - Life Cycle
       
    override func setUp() {
        super.setUp()
        sessionManager = MockSessionManager()
    }

    override func tearDown() {
        sessionManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    // MARK: Fetch
  
    func test_fetch_success_returnsCorrectResponse() {
        let expectation = self.expectation(description: "Finished")
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.subscription)
        let expectedResponse: SRVReceiptResponse = .mock(from: expectedDictionaryResponse)
        sessionManager.stub.start = .success(expectedDictionaryResponse.asData)
        
        let sut = makeSUT()
        sut.fetch(with: .test, sharedSecret: "secret", excludeOldTransactions: false) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedResponse)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_fetch_success_testReceipt_callsSandboxURL() {
        let expectation = self.expectation(description: "Finished")
        let expectedDictionaryResponse: [String: Any] = SRVReceiptResponse.mock(.sandbox)
        sessionManager.stub.start = .success(expectedDictionaryResponse.asData)
        
        let sut = makeSUT()
        sut.fetch(with: .test, sharedSecret: "secret", excludeOldTransactions: false) { result in
            if case .success = result {
                XCTAssertEqual(self.sessionManager.mock.start?.urlString, "sandbox.com")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_fetch_failure_returnsCorrectError() {
        let expectation = self.expectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        sessionManager.stub.start = .failure(expectedError)
        
        let sut = makeSUT()
        sut.fetch(with: .test, sharedSecret: "secret", excludeOldTransactions: false) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: Parameters
    
    func test_fetch_setsCorrectParameters_production() {
        let expectation = self.expectation(description: "Finished")
        
        let receiptURL: URL = .test
        let receiptData = try! Data(contentsOf: receiptURL)
        let expectedParameters = Parameters(
            data: receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
            excludeOldTransactions: false,
            password: "secret"
        )
        sessionManager.stub.start = .success(SRVReceiptResponse.mock(.subscription).asData)
        
        let sut = makeSUT()
        sut.fetch(with: receiptURL,
                  sharedSecret: expectedParameters.password,
                  excludeOldTransactions: expectedParameters.excludeOldTransactions) { result in
            if case .success = result {
                XCTAssertEqual(self.sessionManager.mock.start?.parameters, expectedParameters.asData)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_fetch_setsCorrectParameters_sandbox() {
        let expectation = self.expectation(description: "Finished")
        
        let receiptURL: URL = .test
        let receiptData = try! Data(contentsOf: receiptURL)
        let expectedParameters = Parameters(
            data: receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
            excludeOldTransactions: true,
            password: "abc"
        )
        sessionManager.stub.start = .success(SRVReceiptResponse.mock(.sandbox).asData)
        
        let sut = makeSUT()
        sut.fetch(with: receiptURL,
                  sharedSecret: expectedParameters.password,
                  excludeOldTransactions: expectedParameters.excludeOldTransactions) { result in
            if case .success = result {
                XCTAssertEqual(self.sessionManager.mock.start?.parameters, expectedParameters.asData)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.1)
    }
}

// MARK: - Private Methods

private extension ReceiptClientTests {
    
    func makeSUT() -> ReceiptClient {
        ReceiptClient(
            productionURL: "production.com",
            sandboxURL: "sandbox.com",
            sessionManager: sessionManager,
            isLoggingEnabled: false
        )
    }
}

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
