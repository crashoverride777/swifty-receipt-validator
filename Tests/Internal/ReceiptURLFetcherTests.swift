import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ReceiptURLFetcherTests {
    
    // MARK: - Properties
    
    private let fileManager = MockFileManager()
    private let refreshRequest: MockSKReceiptRefreshRequest
    
    init() {
        refreshRequest = MockSKReceiptRefreshRequest(fileManager: fileManager)
    }
    
    // MARK: - Tests

    @Test func testFetch_whenReceiptOnFile_returnsCorrectData() async throws {
        let expectedURL: URL = .test
        fileManager.stub.fileExists = true
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        let url = try await sut.fetch(refreshRequest: nil)
        #expect(url == expectedURL)
    }
    
    @Test func testFetch_whenNoReceiptOnFile_andNoRefreshRequest_returnsCorrectError() async {
        fileManager.stub.fileExists = false
        let sut = makeSUT()
        await #expect(throws: SRVError.noReceiptFoundInBundle) {
            try await sut.fetch(refreshRequest: nil)
        }
    }
    
    @Test func testFetch_whenNoReceiptOnFile_andRefreshRequestSuccess_returnsCorrectData() async throws {
        let expectedURL: URL = .test
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .success(())
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        let url = try await sut.fetch(refreshRequest: refreshRequest)
        #expect(url == expectedURL)
    }
    
    @Test func testFetch_whenNoReceiptOnFile_andRefreshRequestError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .failure(expectedError)
        let sut = makeSUT()
        await #expect(throws: SRVError.other(expectedError)) {
            try await sut.fetch(refreshRequest: refreshRequest)
        }
    }
    
    @Test func testFetch_whenNoReceiptOnFile_andRefreshRequestSuccess_andStillNoReceipt_returnsCorrectError() async {
        let expectedError: SRVError = .noReceiptFoundInBundle
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .success(())
        refreshRequest.stub.hasReceiptAfterRequest = false
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.fetch(refreshRequest: refreshRequest)
        }
    }
}

// MARK: - Private Methods

private extension ReceiptURLFetcherTests {
    func makeSUT(appStoreReceiptURL: URL = .test) -> ReceiptURLFetcher {
        DefaultReceiptURLFetcher(appStoreReceiptURL: { appStoreReceiptURL }, fileManager: fileManager)
    }
}
