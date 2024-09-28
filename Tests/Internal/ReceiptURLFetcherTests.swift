import Foundation
import Testing
@testable import SwiftyReceiptValidator

final class ReceiptURLFetcherTests {
    
    // MARK: - Properties
    
    private var fileManager: MockFileManager!
    private var refreshRequest: MockSKReceiptRefreshRequest!
    
    // MARK: - Life Cycle
       
    init() {
        fileManager = MockFileManager()
        refreshRequest = MockSKReceiptRefreshRequest(fileManager: fileManager)
    }

    deinit {
        fileManager = nil
        refreshRequest = nil
    }
    
    // MARK: - Tests

    @Test func fetch_whenReceiptOnFile_returnsCorrectData() async {
        let expectedURL: URL = .test
        fileManager.stub.fileExists = true
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        await confirmation { confirmation in
            sut.fetch(refreshRequest: nil) { result in
                if case .success(let url) = result {
                    #expect(url == expectedURL)
                    confirmation()
                }
            }
        }
    }
    
    @Test func fetch_whenNoReceiptOnFile_andNoRefreshRequest_returnsCorrectError() async {
        fileManager.stub.fileExists = false
        let expectedError: SRVError = .noReceiptFoundInBundle
        let sut = makeSUT()
        await confirmation { confirmation in
            sut.fetch(refreshRequest: nil) { result in
                if case .failure(let error) = result {
                    #expect(error.localizedDescription == expectedError.localizedDescription)
                    confirmation()
                }
            }
        }
    }
    
    @Test func fetch_whenNoReceiptOnFile_andRefreshRequestSuccess_returnsCorrectData() async {
        let expectedURL: URL = .test
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .success(())
        let sut = makeSUT(appStoreReceiptURL: expectedURL)
        await confirmation { confirmation in
            sut.fetch(refreshRequest: refreshRequest) { result in
                if case .success(let url) = result {
                    #expect(url == expectedURL)
                    confirmation()
                }
            }
        }
    }
    
    @Test func fetch_whenNoReceiptOnFile_andRefreshRequestError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .failure(expectedError)
        let sut = makeSUT()
        await confirmation { confirmation in
            sut.fetch(refreshRequest: refreshRequest) { result in
                if case .failure(let error) = result {
                    #expect(error.localizedDescription == expectedError.localizedDescription)
                    confirmation()
                }
            }
        }
    }
    
    @Test func fetch_whenNoReceiptOnFile_andRefreshRequestSuccess_andStillNoReceipt_returnsCorrectError() async {
        let expectedError: SRVError = .noReceiptFoundInBundle
        fileManager.stub.fileExists = false
        refreshRequest.stub.start = .success(())
        refreshRequest.stub.hasReceiptAfterRequest = false
        let sut = makeSUT()
        await confirmation { confirmation in
            sut.fetch(refreshRequest: refreshRequest) { result in
                if case .failure(let error) = result {
                    #expect(error.localizedDescription == expectedError.localizedDescription)
                    confirmation()
                }
            }
        }
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
