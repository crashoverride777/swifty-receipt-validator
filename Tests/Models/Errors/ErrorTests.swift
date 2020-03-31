//
//  ErrorTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class ErrorTests: XCTestCase {
    
    // MARK: - Status Code
    
    func test_statusCode_invalidStatusCode() {
        XCTAssertEqual(SRVError.invalidStatusCode(.valid).statusCode, .valid)
    }
    
    func test_statusCode_noReceiptFoundInResponse() {
        XCTAssertEqual(SRVError.noReceiptFoundInResponse(.valid).statusCode, .valid)
    }
    
    func test_statusCode_bundleIdNotMatching() {
        XCTAssertEqual(SRVError.bundleIdNotMatching(.valid).statusCode, .valid)
    }
    
    func test_statusCode_productIdNotMatching() {
        XCTAssertEqual(SRVError.productIdNotMatching(.valid).statusCode, .valid)
    }
    
    func test_statusCode_noValidSubscription() {
        XCTAssertEqual(SRVError.subscriptionExpired(.valid).statusCode, .valid)
    }
    
    func test_statusCode_cancelled() {
        XCTAssertEqual(SRVError.cancelled(.valid).statusCode, .valid)
    }
    
    func test_statusCode_other() {
        let expectedError = URLError(.notConnectedToInternet)
        XCTAssertNil(SRVError.other(expectedError).statusCode)
    }
}
