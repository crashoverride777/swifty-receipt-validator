//
//  MockFileManager.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation

class MockFileManager: FileManager {
    struct Stub {
        var fileExists = false
    }
    
    var stub = Stub()
    
    override func fileExists(atPath path: String) -> Bool {
        stub.fileExists
    }
}
