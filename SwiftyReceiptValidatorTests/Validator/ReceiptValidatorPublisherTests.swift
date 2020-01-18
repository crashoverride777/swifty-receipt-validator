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

@available(iOS 13.0, *)
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
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedResponse: SRVReceiptResponse = .mock()
        receiptClient.stub.validateResult = .success(expectedResponse)
        responseValidator.stub.validatePurchaseResult = .success(expectedResponse)
        sut.validatePurchasePublisher(forId: "1", sharedSecret: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response, expectedResponse)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validPurchasePublisher_failure_receiptFetcher_publishesCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError = URLError(.notConnectedToInternet)
        receiptFetcher.stub.fetchResult = .failure(expectedError)
        sut.validatePurchasePublisher(forId: "1", sharedSecret: nil)
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
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validPurchasePublisher_failure_sessionManager_publishesCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = .failure(.other(expectedError))
        sut.validatePurchasePublisher(forId: "1", sharedSecret: nil)
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
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validPurchasePublisher_failure_responseValidator_publishesCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError: SRVError = .productIdNotMatching(.unknown)
        responseValidator.stub.validatePurchaseResult = .failure(expectedError)
        sut.validatePurchasePublisher(forId: "1", sharedSecret: nil)
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
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    // MARK: Validate Subscription
    
    func test_validSubscriptionPublisher_success_publishesCorrectData() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedReceiptResponse: SRVReceiptResponse = .mock()
        let expectedValidationResponse: SRVSubscriptionValidationResponse = .mock(
            validReceipts: expectedReceiptResponse.validSubscriptionReceipts(now: .test),
            pendingRenewalInfo: expectedReceiptResponse.pendingRenewalInfo ?? []
        )
        receiptClient.stub.validateResult = .success(expectedReceiptResponse)
        responseValidator.stub.validateSubscriptionResult = .success(expectedReceiptResponse)
        sut.validateSubscriptionPublisher(sharedSecret: "123", refreshLocalReceiptIfNeeded: false, excludeOldTransactions: false)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response, expectedValidationResponse)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validSubscriptionPublisher_failure_receiptFetcher_publishesCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError = URLError(.notConnectedToInternet)
        receiptFetcher.stub.fetchResult = .failure(expectedError)
        sut.validateSubscriptionPublisher(sharedSecret: "123", refreshLocalReceiptIfNeeded: false, excludeOldTransactions: false)
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
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validSubscriptionPublisher_failure_sessionManager_publishesCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = .failure(.other(expectedError))
        sut.validateSubscriptionPublisher(sharedSecret: "123", refreshLocalReceiptIfNeeded: false, excludeOldTransactions: false)
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
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_validSubscriptionPublisher_failure_responseValidator_publishesCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError = URLError(.notConnectedToInternet)
        responseValidator.stub.validateSubscriptionResult = .failure(.other(expectedError))
        sut.validateSubscriptionPublisher(sharedSecret: "123", refreshLocalReceiptIfNeeded: false, excludeOldTransactions: false)
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
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    // MARK: Fetch
    
    func test_fetchPublisher_success_publishesCorrectData() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedResponse: SRVReceiptResponse = .mock()
        receiptClient.stub.validateResult = .success(expectedResponse)
        sut.fetchPublisher(sharedSecret: nil, refreshLocalReceiptIfNeeded: false, excludeOldTransactions: false)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response, expectedResponse)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetchPublisher_failure_receiptFetcher_publishesCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError = URLError(.notConnectedToInternet)
        receiptFetcher.stub.fetchResult = .failure(expectedError)
        sut.fetchPublisher(sharedSecret: nil, refreshLocalReceiptIfNeeded: false, excludeOldTransactions: false)
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
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_fetchPublisher_failure_sessionManager_publishesCorrectError() {
        let expectation = self.expectation
        let sut = makeSUT()
        let expectedError = URLError(.notConnectedToInternet)
        receiptClient.stub.validateResult = .failure(.other(expectedError))
        sut.fetchPublisher(sharedSecret: nil, refreshLocalReceiptIfNeeded: false, excludeOldTransactions: false)
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
        
        wait(for: [expectation], timeout: 0.1)
    }
}
