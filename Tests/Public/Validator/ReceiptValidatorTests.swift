import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ReceiptValidatorTests {
    
    // MARK: - Properties
    
    private let receiptURLFetcher = StubReceiptURLFetcher()
    private let receiptClient = StubReceiptClient()
    private let responseValidator = StubResponseValidator()
    
    // MARK: - Tests

    // MARK: Validate Purchase
    
    @Test func testValidatePurchase_whenSuccess_returnsCorrectData() async throws {
        let expectedResponse: SRVReceiptResponse = .mock()
        receiptClient.stub.validationResponse = expectedResponse
        responseValidator.stub.validatePurchaseResponse = expectedResponse
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        let sut = makeSUT()
        let response = try await sut.validate(request)
        #expect(response == expectedResponse)
    }
    
    @Test func testValidatePurchase_whenReceiptFetcherError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchError = expectedError
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validate(request)
        }
    }
    
    @Test func testValidatePurchase_whenReceiptClientError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validationError = expectedError
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validate(request)
        }
    }
    
    @Test func testValidatePurchase_whenResponseValidatorError_returnsCorrectError() async {
        let expectedError: SRVError = .productIdNotMatching(.unknown)
        responseValidator.stub.validatePurchaseError = expectedError
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        let sut = makeSUT()
        await #expect(throws: SRVError.other(expectedError)) {
            try await sut.validate(request)
        }
    }
    
    // MARK: Validate Subscription
    
    @Test func testValidateSubscription_whenSuccess_returnsCorrectData() async throws {
        let expectedReceiptResponse: SRVReceiptResponse = .mock()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        receiptClient.stub.validationResponse = expectedReceiptResponse
        responseValidator.stub.validateSubscriptionResponse = expectedValidationResponse
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )
        let sut = makeSUT()
        let response = try await sut.validate(request)
        #expect(response == expectedValidationResponse)
    }
    
    @Test func testValidateSubscription_whenReceiptFetcherError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchError = expectedError
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validate(request)
        }
    }
    
    @Test func testValidateSubscription_whenReceiptClientError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validationError = expectedError
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validate(request)
        }
    }
    
    @Test func testValidSubscription_whenResponseValidatorError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        responseValidator.stub.validateSubscriptionError = expectedError
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validate(request)
        }
    }
}

// MARK: - Helpers

extension ReceiptValidatorTests {
    func makeSUT(configuration: SRVConfiguration = .standard) -> SwiftyReceiptValidator {
        SwiftyReceiptValidator(
            configuration: configuration,
            receiptURLFetcher: receiptURLFetcher,
            receiptClient: receiptClient,
            responseValidator: responseValidator
        )
    }
}
