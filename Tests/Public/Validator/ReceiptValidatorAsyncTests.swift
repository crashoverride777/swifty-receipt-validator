import XCTest
@testable import SwiftyReceiptValidator

@available(iOS 15, tvOS 15, macOS 12, *)
class ReceiptValidatorAsyncTests: ReceiptValidatorTests {
       
    // MARK: - Tests

    // MARK: Validate Purchase
    
    func test_validPurchasePublisher_success_returnsCorrectData() async throws {
        let expectedResponse: SRVReceiptResponse = .mock()
        receiptClient.stub.validateResult = { (_, _, _) in .success(expectedResponse) }
        responseValidator.stub.validatePurchaseResult = { (_, _) in .success(expectedResponse) }
        let request = SRVPurchaseValidationRequest(productId: "1", sharedSecret: nil)
        
        let sut = makeSUT()
        do {
            let response = try await sut.validate(request)
            XCTAssertEqual(response, expectedResponse)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_validPurchasePublisher_failure_whenReceiptFetcherError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchResult = { _ in .failure(.other(expectedError)) }
        let request = SRVPurchaseValidationRequest(productId: "1", sharedSecret: nil)

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func test_validPurchasePublisher_failure_whenReceiptClientError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = { (_, _, _) in .failure(.other(expectedError)) }
        let request = SRVPurchaseValidationRequest(productId: "1", sharedSecret: nil)

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func test_validPurchasePublisher_failure_whenResponseValidatorError_returnsCorrectError() async throws {
        let expectedError: SRVError = .productIdNotMatching(.unknown)
        responseValidator.stub.validatePurchaseResult = { (_, _) in .failure(expectedError) }
        let request = SRVPurchaseValidationRequest(productId: "1", sharedSecret: nil)

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    // MARK: Validate Subscription
    
    func test_validSubscriptionPublisher_success_returnsCorrectData() async throws {
        let expectedReceiptResponse: SRVReceiptResponse = .mock()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        receiptClient.stub.validateResult = { (_, _, _) in .success(expectedReceiptResponse) }
        responseValidator.stub.validateSubscriptionResult = { (_, _) in .success(expectedValidationResponse) }
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )
        
        let sut = makeSUT()
        do {
            let response = try await sut.validate(request)
            XCTAssertEqual(response, expectedValidationResponse)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_validSubscriptionPublisher_failure_whenReceiptFetcherError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchResult = { _ in .failure(.other(expectedError)) }
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func test_validSubscriptionPublisher_failure_whenReceiptClientError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = { (_, _, _) in .failure(.other(expectedError)) }
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func test_validSubscriptionPublisher_failure_whenResponseValidatorError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        responseValidator.stub.validateSubscriptionResult = { (_, _) in .failure(.other(expectedError)) }
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
}
