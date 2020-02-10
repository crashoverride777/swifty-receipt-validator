//
//  URLSessionManagerTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class URLSessionManagerTests: XCTestCase {

    // MARK: - Tests

    func test_error_descriptions() {
        XCTAssertEqual(
            URLSessionManager.SessionError.url.localizedDescription,
            LocalizedString.Error.SessionManager.url
        )
        XCTAssertEqual(
            URLSessionManager.SessionError.parameterEncoding.localizedDescription,
            LocalizedString.Error.SessionManager.parameterEncoding
        )
        XCTAssertEqual(
            URLSessionManager.SessionError.data.localizedDescription,
            LocalizedString.Error.SessionManager.data
        )
    }
    
    #warning("add remaining tests")
}
