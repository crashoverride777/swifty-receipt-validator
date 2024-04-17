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

    func test_fetch_whenReceiptOnFile_returnsCorrectData() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedURL: URL = .test
        fileManager.stub.fileExists = true
        
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        sut.fetch(refreshRequest: nil) { result in
            if case .success(let url) = result {
                XCTAssertEqual(url, expectedURL)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_whenNoReceiptOnFile_andNoRefreshRequest_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        fileManager.stub.fileExists = false
        let expectedError: SRVError = .noReceiptFoundInBundle
        
        let sut = makeSUT()
        sut.fetch(refreshRequest: nil) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_whenNoReceiptOnFile_andRefreshRequestSuccess_returnsCorrectData() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedURL: URL = .test
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .success(())

        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        sut.fetch(refreshRequest: refreshRequest) { result in
            if case .success(let url) = result {
                XCTAssertEqual(url, expectedURL)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_whenNoReceiptOnFile_andRefreshRequestError_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .failure(expectedError)
        
        let sut = makeSUT()
        sut.fetch(refreshRequest: refreshRequest) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetch_whenNoReceiptOnFile_andRefreshRequestSuccess_andStillNoReceipt_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError: SRVError = .noReceiptFoundInBundle
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .success(())
        refreshRequest.stub.hasReceiptAfterRequest = false
        
        let sut = makeSUT()
        sut.fetch(refreshRequest: refreshRequest) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }
}

// MARK: - Private Methods

private extension ReceiptURLFetcherTests {
    func makeSUT(appStoreReceiptURL: URL = .test) -> ReceiptURLFetcher {
        DefaultReceiptURLFetcher(
            appStoreReceiptURL: { appStoreReceiptURL },
            fileManager: fileManager
        )
    }
}
