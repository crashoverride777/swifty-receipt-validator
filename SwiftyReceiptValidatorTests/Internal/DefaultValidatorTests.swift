//
//  DefaultValidatorTests.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import XCTest
@testable import SwiftyReceiptValidator

class DefaultValidatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: SwiftyReceiptValidatorType!
    
    // MARK: - Life Cycle
    
    override func setUp() {
        super.setUp()
        sut = DefaultValidator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    #warning("add tests")
}
