//
//  ResponseValidatorTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class ResponseValidatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var bundle: MockBundle!
    
    // MARK: - Computed Properties
      
    private var expectation: XCTestExpectation {
        XCTestExpectation(description: "Expectation Succeeded")
    }
    
    // MARK: - Life Cycle
       
    override func setUp() {
        super.setUp()
        bundle = MockBundle()
    }

    override func tearDown() {
        bundle = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    // MARK: Validate Purchase

    func test_validatePurchase_success_returnsCorrectData() {
        let expectation = self.expectation
        let sut = makeSUT()
        let productId = "123"
        let expectedResponse = makeResponse(productId: productId)
        sut.validatePurchase(forProductId: productId, in: expectedResponse) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedResponse)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validatePurchase_failure_basicValidation_statusCode_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError: SRVError = .invalidStatusCode(.jsonNotReadable)
        let expectedResponse = makeResponse(statusCode: .jsonNotReadable)
        sut.validatePurchase(forProductId: "1", in: expectedResponse) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validatePurchase_failure_basicValidation_unwrap_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError: SRVError = .noReceiptFoundInResponse(.valid)
        let expectedResponse = makeResponseWithNilReceipt()
        sut.validatePurchase(forProductId: "1", in: expectedResponse) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validatePurchase_failure_basicValidation_bundleIdNotMatching_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        bundle.stub.bundleIdentifier = "invalid"
        let expectedError: SRVError = .bundleIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        sut.validatePurchase(forProductId: "1", in: expectedResponse) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validatePurchase_failure_productIdNotMatching_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError: SRVError = .productIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        sut.validatePurchase(forProductId: "invalid", in: expectedResponse) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validatePurchase_failure_cancelled_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError: SRVError = .cancelled(.valid)
        let expectedResponse = makeResponse(cancellationDate: .test)
        sut.validatePurchase(forProductId: "1", in: expectedResponse) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    // MARK: Validate Subscription

    func test_validateSubscription_success_returnsCorrectData() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedReceiptResponse = makeResponse()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        sut.validateSubscriptions(in: expectedReceiptResponse, now: .test) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedValidationResponse)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validateSubscription_success_noValidSubscriptionsFound_returnsCorrectResponse() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedReceiptResponse = makeEmptyResponse()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            receiptResponse: expectedReceiptResponse
        )
        sut.validateSubscriptions(in: expectedReceiptResponse, now: .test) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response, expectedValidationResponse)
                expectation.fulfill()
            }
        }
          
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validateSubscription_failure_basicValidation_statusCode_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError: SRVError = .invalidStatusCode(.jsonNotReadable)
        let expectedResponse = makeResponse(statusCode: .jsonNotReadable)
        sut.validateSubscriptions(in: expectedResponse, now: .test) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validateSubscription_failure_basicValidation_unwrap_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError: SRVError = .noReceiptFoundInResponse(.jsonNotReadable)
        let expectedResponse = makeResponseWithNilReceipt()
        sut.validateSubscriptions(in: expectedResponse, now: .test) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validateSubscription_failure_basicValidation_bundleIdNotMatching_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        bundle.stub.bundleIdentifier = "invalid"
        let expectedError: SRVError = .bundleIdNotMatching(.valid)
        let expectedResponse = makeResponse()
        sut.validateSubscriptions(in: expectedResponse, now: .test) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validateSubscription_failure_statusCodeExpired_returnsCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError: SRVError = .noValidSubscription(.subscriptionExpired)
        let expectedResponse = makeResponse(statusCode: .subscriptionExpired)
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
        bundle.stub.bundleIdentifier = "test.com"
        return ResponseValidator(bundle: bundle)
    }
    
    func makeResponse(statusCode: SRVStatusCode = .valid,
                      productId: String = "1",
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
