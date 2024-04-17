import XCTest
@testable import SwiftyReceiptValidator

class ReceiptValidatorAsyncTests: ReceiptValidatorTests {
       
    // MARK: - Tests

    // MARK: Validate Purchase
    
    func testValidatePurchaseAsync_whenSuccess_returnsCorrectData() async throws {
        let expectedResponse: SRVReceiptResponse = .mock()
        receiptClient.stub.validateResult = { (_, _, _) in .success(expectedResponse) }
        responseValidator.stub.validatePurchaseResult = { (_, _) in .success(expectedResponse) }
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        
        let sut = makeSUT()
        do {
            let response = try await sut.validate(request)
            XCTAssertEqual(response, expectedResponse)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testValidatePurchaseAsync_whenReceiptFetcherError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchResult = { _ in .failure(.other(expectedError)) }
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testValidatePurchaseAsync_whenReceiptClientError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = { (_, _, _) in .failure(expectedError) }
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testValidatePurchaseAsync_whenResponseValidatorError_returnsCorrectError() async throws {
        let expectedError: SRVError = .productIdNotMatching(.unknown)
        responseValidator.stub.validatePurchaseResult = { (_, _) in .failure(expectedError) }
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)

        let sut = makeSUT()
        do {
            _ = try await sut.validate(request)
        } catch {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    // MARK: Validate Subscription
    
    func testValidateSubscriptionAsync_whenSuccess_returnsCorrectData() async throws {
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
    
    func testValidateSubscriptionAsync_whenReceiptFetcherError_returnsCorrectError() async throws {
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
    
    func testValidateSubscriptionAsync_whenReceiptClientError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = { (_, _, _) in .failure(expectedError) }
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
    
    func testValidSubscriptionAsync_whenResponseValidatorError_returnsCorrectError() async throws {
        let expectedError = URLError(.notConnectedToInternet)
        responseValidator.stub.validateSubscriptionResult = { (_, _) in .failure(expectedError) }
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
