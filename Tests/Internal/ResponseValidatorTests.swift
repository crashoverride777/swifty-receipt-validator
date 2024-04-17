import XCTest
@testable import SwiftyReceiptValidator

final class ResponseValidatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var bundle: MockBundle!

    // MARK: - Life Cycle
       
    override func setUp() {
        super.setUp()
        bundle = MockBundle()
        bundle.stub.bundleIdentifier = "test.com"
    }

    override func tearDown() {
        bundle = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    // MARK: Validate Purchase

    func testValidatePurchase_whenSuccess_returnsCorrectData() {
        let expectation = XCTestExpectation(description: "Finished")
        let productId = "123"
        let expectedResponse = makeResponse(productId: productId)
        
        let sut = makeSUT()
        sut.validatePurchase(in: expectedResponse, productId: productId) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedResponse)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidatePurchase_whenInvalidStatusCode_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError: SRVError = .invalidStatusCode(.jsonNotReadable)
        let expectedResponse = makeResponse(statusCode: .jsonNotReadable)
        
        let sut = makeSUT()
        sut.validatePurchase(in: expectedResponse, productId: "123") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidatePurchase_whenNoReceiptFoundInResponse_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError: SRVError = .noReceiptFoundInResponse(.valid)
        let expectedResponse = makeResponseWithNilReceipt()
        
        let sut = makeSUT()
        sut.validatePurchase(in: expectedResponse, productId: "123") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidatePurchase_whenBundleIDNotMatching_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        bundle.stub.bundleIdentifier = "invalid"
        let expectedError: SRVError = .bundleIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        
        let sut = makeSUT()
        sut.validatePurchase(in: expectedResponse, productId: "123") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidatePurchase_whenProductIdNotMatching_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError: SRVError = .productIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        
        let sut = makeSUT()
        sut.validatePurchase(in: expectedResponse, productId: "invalid") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidatePurchase_whenPurchaseCancelled_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError: SRVError = .purchaseCancelled(.valid)
        let expectedResponse = makeResponse(cancellationDate: .test)
        
        let sut = makeSUT()
        sut.validatePurchase(in: expectedResponse, productId: "123") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    // MARK: Validate Subscription

    func testValidateSubscription_whenSuccess_returnsCorrectData() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedReceiptResponse = makeResponse()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        
        let sut = makeSUT()
        sut.validateSubscriptions(in: expectedReceiptResponse, now: .test) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedValidationResponse)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidateSubscription_whenNoValidSubscriptionsFound_returnsCorrectResponse() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedReceiptResponse = makeEmptyResponse()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        
        let sut = makeSUT()
        sut.validateSubscriptions(in: expectedReceiptResponse, now: .test) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedValidationResponse)
                expectation.fulfill()
            }
        }
          
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidateSubscription_whenInvalidStatusCode_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError: SRVError = .invalidStatusCode(.jsonNotReadable)
        let expectedResponse = makeResponse(statusCode: .jsonNotReadable)
        
        let sut = makeSUT()
        sut.validateSubscriptions(in: expectedResponse, now: .test) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidateSubscription_whenNoReceiptFoundInResponse_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError: SRVError = .noReceiptFoundInResponse(.jsonNotReadable)
        let expectedResponse = makeResponseWithNilReceipt()
        
        let sut = makeSUT()
        sut.validateSubscriptions(in: expectedResponse, now: .test) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidateSubscription_whenBundleIdNotMatching_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        bundle.stub.bundleIdentifier = "invalid"
        let expectedError: SRVError = .bundleIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        
        let sut = makeSUT()
        sut.validateSubscriptions(in: expectedResponse, now: .test) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidateSubscription_whenSubscriptioniOS6StyleExpired_returnsCorrectError() {
        let expectation = XCTestExpectation(description: "Finished")
        let expectedError: SRVError = .subscriptioniOS6StyleExpired(.subscriptioniOS6StyleExpired)
        let expectedResponse = makeResponse(statusCode: .subscriptioniOS6StyleExpired)
        
        let sut = makeSUT()
        sut.validateSubscriptions(in: expectedResponse, now: .test) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
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
