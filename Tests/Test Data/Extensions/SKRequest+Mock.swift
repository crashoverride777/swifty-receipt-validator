//
//  SKRequest+Mock.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation
import StoreKit

extension SKRequest {
    
    convenience init(id: String = "123") {
        self.init()
    }
    
    static func mock() -> SKRequest {
        SKRequest()
    }
}
