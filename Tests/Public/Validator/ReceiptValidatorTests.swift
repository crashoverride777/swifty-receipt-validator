import Foundation
import Testing
@testable import SwiftyReceiptValidator

final class ReceiptValidatorTests {
    
    // MARK: - Properties
    
    private var receiptURLFetcher: StubReceiptURLFetcher!
    private var receiptClient: StubReceiptClient!
    private var responseValidator: StubResponseValidator!
    
    // MARK: - Life Cycle
    
    init() {
        receiptURLFetcher = StubReceiptURLFetcher()
        receiptClient = StubReceiptClient()
        responseValidator = StubResponseValidator()
    }

    deinit {
        receiptURLFetcher = nil
        receiptClient = nil
        responseValidator = nil
    }
    
    // MARK: - Tests

    // MARK: Validate Purchase
    
    @Test func validatePurchase_whenSuccess_returnsCorrectData() async throws {
        let expectedResponse: SRVReceiptResponse = .mock()
        receiptClient.stub.response = expectedResponse
        responseValidator.stub.validatePurchaseResponse = expectedResponse
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        let sut = makeSUT()
        let response = try await sut.validate(request)
        #expect(response == expectedResponse)
    }
    
    @Test func validatePurchase_whenReceiptFetcherError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchResult = { _ in .failure(expectedError) }
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validate(request)
        }
    }
    
    @Test func validatePurchase_whenReceiptClientError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.error = expectedError
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validate(request)
        }
    }
    
    @Test func validatePurchase_whenResponseValidatorError_returnsCorrectError() async {
        let expectedError: SRVError = .productIdNotMatching(.unknown)
        responseValidator.stub.validatePurchaseError = expectedError
        let request = SRVPurchaseValidationRequest(productIdentifier: "1", sharedSecret: nil)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validate(request)
        }
    }
    
    // MARK: Validate Subscription
    
    @Test func validateSubscription_whenSuccess_returnsCorrectData() async throws {
        let expectedReceiptResponse: SRVReceiptResponse = .mock()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        receiptClient.stub.response = expectedReceiptResponse
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
    
    @Test func validateSubscription_whenReceiptFetcherError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchResult = { _ in .failure(expectedError) }
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
    
    @Test func validateSubscription_whenReceiptClientError_returnsCorrectError() async {
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.error = expectedError
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
    
    @Test func validSubscription_whenResponseValidatorError_returnsCorrectError() async {
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

// MARK: - Internal Methods

extension ReceiptValidatorTests {
    func makeSUT(configuration: SRVConfiguration = .standard) -> SwiftyReceiptValidator {
        DefaultSwiftyReceiptValidator(
            configuration: configuration,
            receiptURLFetcher: receiptURLFetcher,
            receiptClient: receiptClient,
            responseValidator: responseValidator
        )
    }
}
