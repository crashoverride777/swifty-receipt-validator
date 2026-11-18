import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct ResponseValidatorTests {
    
    // MARK: - Properties
    
    private let bundle = MockBundle()

    // MARK: - Life Cycle
       
    init() {
        bundle.stub.bundleIdentifier = "test.com"
    }
    
    // MARK: - Tests
    
    // MARK: Validate Purchase

    @Test func testValidatePurchase_whenSuccess_returnsCorrectData() async throws {
        let productId = "123"
        let expectedResponse = makeResponse(productId: productId)
        let sut = makeSUT()
        let response = try await sut.validatePurchase(in: expectedResponse, productId: productId)
        #expect(response == expectedResponse)
    }
    
    @Test func testValidatePurchase_whenInvalidStatusCode_returnsCorrectError() async {
        let expectedError: SRVError = .invalidStatusCode(.jsonNotReadable)
        let expectedResponse = makeResponse(statusCode: .jsonNotReadable)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validatePurchase(in: expectedResponse, productId: "123")
        }
    }
    
    @Test func testValidatePurchase_whenNoReceiptFoundInResponse_returnsCorrectError() async {
        let expectedError: SRVError = .noReceiptFoundInResponse(.valid)
        let expectedResponse = makeResponseWithNilReceipt()
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validatePurchase(in: expectedResponse, productId: "123")
        }
    }
    
    @Test func testValidatePurchase_whenBundleIDNotMatching_returnsCorrectError() async {
        bundle.stub.bundleIdentifier = "invalid"
        let expectedError: SRVError = .bundleIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validatePurchase(in: expectedResponse, productId: "123")
        }
    }
    
    @Test func testValidatePurchase_whenProductIdNotMatching_returnsCorrectError() async {
        let expectedError: SRVError = .productIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validatePurchase(in: expectedResponse, productId: "invalid")
        }
    }
    
    @Test func testValidatePurchase_whenPurchaseCancelled_returnsCorrectError() async {
        let expectedError: SRVError = .purchaseCancelled(.valid)
        let expectedResponse = makeResponse(cancellationDate: .test)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validatePurchase(in: expectedResponse, productId: "123")
        }
    }
    
    // MARK: Validate Subscription

    @Test func testValidateSubscription_whenSuccess_returnsCorrectData() async throws {
        let expectedReceiptResponse = makeResponse()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        let sut = makeSUT()
        let response = try await sut.validateSubscriptions(in: expectedReceiptResponse, now: .test)
        #expect(response == expectedValidationResponse)
    }
    
    @Test func testValidateSubscription_whenNoValidSubscriptionsFound_returnsCorrectResponse() async throws {
        let expectedReceiptResponse = makeEmptyResponse()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        let sut = makeSUT()
        let response = try await sut.validateSubscriptions(in: expectedReceiptResponse, now: .test)
        #expect(response == expectedValidationResponse)
    }
    
    @Test func testValidateSubscription_whenInvalidStatusCode_returnsCorrectError() async {
        let expectedError: SRVError = .invalidStatusCode(.jsonNotReadable)
        let expectedResponse = makeResponse(statusCode: .jsonNotReadable)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validateSubscriptions(in: expectedResponse, now: .test)
        }
    }
    
    @Test func testValidateSubscription_whenNoReceiptFoundInResponse_returnsCorrectError() async {
        let expectedError: SRVError = .noReceiptFoundInResponse(.jsonNotReadable)
        let expectedResponse = makeResponseWithNilReceipt()
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validateSubscriptions(in: expectedResponse, now: .test)
        }
    }
    
    @Test func testValidateSubscription_whenBundleIdNotMatching_returnsCorrectError() async {
        bundle.stub.bundleIdentifier = "invalid"
        let expectedError: SRVError = .bundleIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validateSubscriptions(in: expectedResponse, now: .test)
        }
    }
    
    @Test func testValidateSubscription_whenSubscriptioniOS6StyleExpired_returnsCorrectError() async {
        let expectedError: SRVError = .subscriptioniOS6StyleExpired(.subscriptioniOS6StyleExpired)
        let expectedResponse = makeResponse(statusCode: .subscriptioniOS6StyleExpired)
        let sut = makeSUT()
        await #expect(throws: expectedError) {
            try await sut.validateSubscriptions(in: expectedResponse, now: .test)
        }
    }
}

// MARK: - Private Methods

private extension ResponseValidatorTests {
    func makeSUT() -> ResponseValidator {
        DefaultResponseValidator(bundle: bundle, isLoggingEnabled: false)
    }
    
    func makeResponse(statusCode: SRVStatusCode = .valid,
                      productId: String = "123",
                      cancellationDate: Date? = nil) -> SRVReceiptResponse {
        .mock(
            statusCode: statusCode,
            receipt: .mock(inApp: [.mock(productId: productId, cancellationDate: cancellationDate)]),
            latestReceiptInfo: [.mock(productId: productId, cancellationDate: cancellationDate)]
        )
    }
    
    func makeEmptyResponse(statusCode: SRVStatusCode = .valid) -> SRVReceiptResponse {
        .mock(statusCode: statusCode, receipt: .mock(inApp: []), latestReceiptInfo: [])
    }
    
    func makeResponseWithNilReceipt(statusCode: SRVStatusCode = .valid) -> SRVReceiptResponse {
        .mock(statusCode: statusCode, receipt: nil, latestReceiptInfo: [])
    }
}
