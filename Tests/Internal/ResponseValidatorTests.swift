import Foundation
import Testing
@testable import SwiftyReceiptValidator

final class ResponseValidatorTests {
    
    // MARK: - Properties
    
    private var bundle: MockBundle!

    // MARK: - Life Cycle
       
    init() {
        bundle = MockBundle()
        bundle.stub.bundleIdentifier = "test.com"
    }

    deinit {
        bundle = nil
    }
    
    // MARK: - Tests
    
    // MARK: Validate Purchase

    @Test func validatePurchase_whenSuccess_returnsCorrectData() async throws {
        let productID = "123"
        let expectedResponse = makeResponse(productId: productID)
        let sut = makeSUT()
        let response = try await sut.validatePurchase(for: expectedResponse, productID: productID)
        #expect(response == expectedResponse)
    }
    
    @Test func validatePurchase_whenInvalidStatusCode_returnsCorrectError() async {
        let expectedResponse = makeResponse(statusCode: .jsonNotReadable)
        let sut = makeSUT()
        await #expect(throws: SRVError.invalidStatusCode(.jsonNotReadable)) {
            try await sut.validatePurchase(for: expectedResponse, productID: "123")
        }
    }
    
    @Test func validatePurchase_whenNoReceiptFoundInResponse_returnsCorrectError() async {
        let expectedResponse = makeResponseWithNilReceipt()
        let sut = makeSUT()
        await #expect(throws: SRVError.noReceiptFoundInResponse(.valid)) {
            try await sut.validatePurchase(for: expectedResponse, productID: "123")
        }
    }
    
    @Test func validatePurchase_whenBundleIDNotMatching_returnsCorrectError() async {
        bundle.stub.bundleIdentifier = "invalid"
        let expectedResponse = makeResponse()
        let sut = makeSUT()
        await #expect(throws: SRVError.bundleIdNotMatching(.valid)) {
            try await sut.validatePurchase(for: expectedResponse, productID: "123")
        }
    }
    
    @Test func validatePurchase_whenProductIdNotMatching_returnsCorrectError() async {
        let expectedResponse = makeResponse()
        let sut = makeSUT()
        await #expect(throws: SRVError.productIdNotMatching(.valid)) {
            try await sut.validatePurchase(for: expectedResponse, productID: "invalid")
        }
    }
    
    @Test func validatePurchase_whenPurchaseCancelled_returnsCorrectError() async {
        let expectedResponse = makeResponse(cancellationDate: .test)
        let sut = makeSUT()
        await #expect(throws: SRVError.purchaseCancelled(.valid)) {
            try await sut.validatePurchase(for: expectedResponse, productID: "123")
        }
    }
    
    // MARK: Validate Subscription

    @Test func validateSubscription_whenSuccess_returnsCorrectData() async throws {
        let expectedReceiptResponse = makeResponse()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        let sut = makeSUT()
        let response = try await sut.validateSubscriptions(for: expectedReceiptResponse, now: .test)
        #expect(response == expectedValidationResponse)
    }
    
    @Test func validateSubscription_whenNoValidSubscriptionsFound_returnsCorrectResponse() async throws {
        let expectedReceiptResponse = makeEmptyResponse()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        
        let sut = makeSUT()
        let response = try await sut.validateSubscriptions(for: expectedReceiptResponse, now: .test)
        #expect(response == expectedValidationResponse)
    }
    
    @Test func validateSubscription_whenInvalidStatusCode_returnsCorrectError() async {
        let expectedResponse = makeResponse(statusCode: .jsonNotReadable)
        let sut = makeSUT()
        await #expect(throws: SRVError.invalidStatusCode(.jsonNotReadable)) {
            try await sut.validateSubscriptions(for: expectedResponse, now: .test)
        }
    }
    
    @Test func validateSubscription_whenNoReceiptFoundInResponse_returnsCorrectError() async {
        let expectedResponse = makeResponseWithNilReceipt()
        let sut = makeSUT()
        await #expect(throws: SRVError.noReceiptFoundInResponse(.valid)) {
            try await sut.validateSubscriptions(for: expectedResponse, now: .test)
        }
    }
    
    @Test func validateSubscription_whenBundleIdNotMatching_returnsCorrectError() async {
        bundle.stub.bundleIdentifier = "invalid"
        let expectedResponse = makeResponse()
        let sut = makeSUT()
        await #expect(throws: SRVError.bundleIdNotMatching(.valid)) {
            try await sut.validateSubscriptions(for: expectedResponse, now: .test)
        }
    }
    
    @Test func validateSubscription_whenSubscriptioniOS6StyleExpired_returnsCorrectError() async {
        let expectedResponse = makeResponse(statusCode: .subscriptioniOS6StyleExpired)
        let sut = makeSUT()
        await #expect(throws: SRVError.subscriptioniOS6StyleExpired(.subscriptioniOS6StyleExpired)) {
            try await sut.validateSubscriptions(for: expectedResponse, now: .test)
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
        .mock(
            statusCode: statusCode,
            receipt: .mock(inApp: []),
            latestReceiptInfo: []
        )
    }
    
    func makeResponseWithNilReceipt(statusCode: SRVStatusCode = .valid) -> SRVReceiptResponse {
        .mock(
            statusCode: statusCode,
            receipt: nil,
            latestReceiptInfo: []
        )
    }
}
