//
//  ReceiptURLFetcherTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class ReceiptURLFetcherTests: XCTestCase {
    
    // MARK: - Properties
    
    private var fileManager: MockFileManager!
    private var refreshRequest: MockSKReceiptRefreshRequest!
    
    // MARK: - Life Cycle
       
    override func setUp() {
        super.setUp()
        fileManager = MockFileManager()
        refreshRequest = MockSKReceiptRefreshRequest(fileManager: fileManager)
    }

    override func tearDown() {
        fileManager = nil
        refreshRequest = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    func test_fetch_success_hasReceiptOnFile_returnsCorrectData() {
        let expectation = self.expectation(description: "Finished")
        let expectedURL: URL = .test
        fileManager.stub.fileExists = true
        
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        sut.fetch(refreshRequest: nil) { result in
            if case .success(let url) = result {
                XCTAssertEqual(url, expectedURL)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_fetch_success_noReceiptOnFile_returnsCorrectData() {
        let expectation = self.expectation(description: "Finished")
        let expectedURL: URL = .test
        fileManager.stub.fileExists = false
        
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        sut.fetch(refreshRequest: refreshRequest) { result in
            if case .success(let url) = result {
                XCTAssertEqual(url, expectedURL)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_fetch_failure_noReceiptOnFile_noRefreshRequest_returnsCorrectError() {
        let expectation = self.expectation(description: "Finished")
        fileManager.stub.fileExists = false
        let expectedError: SRVError = .noReceiptFoundInBundle
        
        let sut = makeSUT()
        sut.fetch(refreshRequest: nil) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_fetch_failure_noReceiptOnFile_refreshRequest_returnsCorrectError() {
        let expectation = self.expectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        refreshRequest.stub.start = .failure(expectedError)
        
        let sut = makeSUT()
        sut.fetch(refreshRequest: refreshRequest) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.1)
    }
}

// MARK: - Private Methods

private extension ReceiptURLFetcherTests {
    
    func makeSUT(appStoreReceiptURL: URL = .test) -> ReceiptURLFetcher {
        ReceiptURLFetcher(
            appStoreReceiptURL: { appStoreReceiptURL },
            fileManager: fileManager
        )
    }
}
