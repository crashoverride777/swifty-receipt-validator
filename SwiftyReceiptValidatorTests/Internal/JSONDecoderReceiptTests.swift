//
//  JSONDecoderReceiptTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 19/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class JSONDecoderReceiptTests: XCTestCase {

    // MARK: - Tests

    func test_dateDecodingStrategy() {
        let sut: JSONDecoder = .receiptResponse
        switch sut.dateDecodingStrategy {
        case .formatted:
            break
        default:
            XCTFail("Wrong keyDecodingStrategy")
        }
    }
    
    func test_keyDecodingStrategy() {
        let sut: JSONDecoder = .receiptResponse
        switch sut.keyDecodingStrategy {
        case .convertFromSnakeCase:
            break
        default:
            XCTFail("Wrong dateDecodingStrategy")
        }
    }
}
