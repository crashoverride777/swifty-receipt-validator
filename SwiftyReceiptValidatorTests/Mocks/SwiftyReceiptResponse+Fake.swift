//
//  SwiftyReceiptResponse+Fake.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 15/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

extension SwiftyReceiptResponse {
    
    static func fake(status: SwiftyReceiptResponse.StatusCode = .valid) -> SwiftyReceiptResponse {
        #warning("fix, decode mock JSON from bundle")
        return SwiftyReceiptResponse(
            status: status,
            receipt: nil,
            latestReceipt: nil,
            latestReceiptInfo: [],
            pendingRenewalInfo: [],
            environment: nil
        )
    }
}
