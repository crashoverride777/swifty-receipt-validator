//
//  MockSKReceiptRequest.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation
import StoreKit

final class MockSKReceiptRefreshRequest: SKReceiptRefreshRequest {
    struct Stub {
        var start: Result<Void, Error> = .success(())
    }

    var stub = Stub()
    private let fileManager: MockFileManager
    
    init(fileManager: MockFileManager) {
        self.fileManager = fileManager
        super.init()
    }
    
    override func start() {
        switch stub.start {
        case .success:
            fileManager.stub.fileExists = true
            delegate?.requestDidFinish?(.mock())
        case .failure(let error):
            delegate?.request?(.mock(), didFailWithError: error)
            
        }
    }
}
