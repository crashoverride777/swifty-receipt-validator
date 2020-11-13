//
//  ReceiptValidatorPublisherTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 27/02/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
import Combine
@testable import SwiftyReceiptValidator

@available(iOS 13, tvOS 13, macOS 10.15, *)
class ReceiptValidatorPublisherTests: ReceiptValidatorTests {
    
    // MARK: - Properties
    
    private var cancellables: Set<AnyCancellable>!
   
    // MARK: - Life Cycle
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    // MARK: Validate Purchase
    
    func test_validPurchasePublisher_success_publishesCorrectData() {
        let expectation = self.expectation(description: "Finished")
        let expectedResponse: SRVReceiptResponse = .mock()
        receiptClient.stub.validateResult = { (_, _, _) in .success(expectedResponse) }
        responseValidator.stub.validatePurchaseResult = { (_, _) in .success(expectedResponse) }
        let request = SRVPurchaseValidationRequest(productId: "1", sharedSecret: nil)
        
        let sut = makeSUT()
        sut.validatePublisher(for: request)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response, expectedResponse)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_validPurchasePublisher_failure_receiptFetcher_publishesCorrectError() {
        let expectation = self.expectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchResult = { _ in .failure(.other(expectedError)) }
        let request = SRVPurchaseValidationRequest(productId: "1", sharedSecret: nil)
        
        let sut = makeSUT()
        sut.validatePublisher(for: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_validPurchasePublisher_failure_receiptClient_publishesCorrectError() {
        let expectation = self.expectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = { (_, _, _) in .failure(.other(expectedError)) }
        let request = SRVPurchaseValidationRequest(productId: "1", sharedSecret: nil)
        
        let sut = makeSUT()
        sut.validatePublisher(for: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_validPurchasePublisher_failure_responseValidator_publishesCorrectError() {
        let expectation = self.expectation(description: "Finished")
        let expectedError: SRVError = .productIdNotMatching(.unknown)
        responseValidator.stub.validatePurchaseResult = { (_, _) in .failure(expectedError) }
        let request = SRVPurchaseValidationRequest(productId: "1", sharedSecret: nil)
        
        let sut = makeSUT()
        sut.validatePublisher(for: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: Validate Subscription
    
    func test_validSubscriptionPublisher_success_publishesCorrectData() {
        let expectation = self.expectation(description: "Finished")
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
        sut.validatePublisher(for: request)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response, expectedValidationResponse)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_validSubscriptionPublisher_failure_receiptFetcher_publishesCorrectError() {
        let expectation = self.expectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        receiptURLFetcher.stub.fetchResult = { _ in .failure(.other(expectedError)) }
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )
        
        let sut = makeSUT()
        sut.validatePublisher(for: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_validSubscriptionPublisher_failure_receiptClient_publishesCorrectError() {
        let expectation = self.expectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = { (_, _, _) in .failure(.other(expectedError)) }
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )
        
        let sut = makeSUT()
        sut.validatePublisher(for: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_validSubscriptionPublisher_failure_responseValidator_publishesCorrectError() {
        let expectation = self.expectation(description: "Finished")
        let expectedError = URLError(.notConnectedToInternet)
        responseValidator.stub.validateSubscriptionResult = { (_, _) in .failure(.other(expectedError)) }
        let request = SRVSubscriptionValidationRequest(
            sharedSecret: "secret",
            refreshLocalReceiptIfNeeded: false,
            excludeOldTransactions: false,
            now: .test
        )
        
        let sut = makeSUT()
        sut.validatePublisher(for: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.1)
    }
}
