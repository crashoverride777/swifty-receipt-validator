//
//  BundleReceiptFetcherTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class BundleReceiptFetcherTests: XCTestCase {
    
    // MARK: - Properties
    
    private var fileManager: MockFileManager!

    // MARK: - Computed Properties
    
    private var expectation: XCTestExpectation {
        XCTestExpectation(description: "Expectation Succeeded")
    }
    
    // MARK: - Life Cycle
       
    override func setUp() {
        super.setUp()
        fileManager = MockFileManager()
    }

    override func tearDown() {
        fileManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    #warning("add more tests")
    
    func test_fetch_success_hasReceiptOnFile_returnsCorrectData() {
        let expectation = self.expectation
        let expectedURL: URL = .test
        fileManager.stub.fileExists = true
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        sut.fetch(requestRefreshIfNoneFound: false) { result in
            if case .success(let url) = result {
                XCTAssertEqual(url, expectedURL)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_success_noReceiptOnFile_returnsCorrectData() {
        let expectation = self.expectation
        let expectedURL: URL = .test
        fileManager.stub.fileExists = false
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        sut.fetch(requestRefreshIfNoneFound: true) { result in
            if case .success(let url) = result {
                XCTAssertEqual(url, expectedURL)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_failure_noReceiptOnFile_noRefreshIfNeeded_returnsCorrectError() {
        let expectation = self.expectation
        fileManager.stub.fileExists = false
        let expectedError: SRVError = .noReceiptFound
        let sut = makeSUT()
        sut.fetch(requestRefreshIfNoneFound: false) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
//    func test_fetch_failure_returnsCorrectError() {
//        let expectation = self.expectation
//        let expectedError = URLError(.notConnectedToInternet)
//        let sut = makeSUT()
//        sut.fetch(requestRefreshIfNoneFound: true) { result in
//            if case .failure(let error) = result {
//                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
//                expectation.fulfill()
//            }
//        }
//
//        wait(for: [expectation], timeout: 0.1)
//    }
}

// MARK: - Private Methods

private extension BundleReceiptFetcherTests {
    
    func makeSUT(appStoreReceiptURL: URL = .test) -> BundleReceiptFetcher {
        BundleReceiptFetcher(
            appStoreReceiptURL: { appStoreReceiptURL },
            fileManager: fileManager
        )
    }
}
