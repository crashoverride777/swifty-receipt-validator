//
//  SwiftyReceiptPendingRenewalInfo+Mock.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 27/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

extension SwiftyReceiptPendingRenewalInfo {
    
    static func mock(productId: String = "123",
                     autoRenewProductId: String = "abs") -> SwiftyReceiptPendingRenewalInfo {
        return SwiftyReceiptPendingRenewalInfo(
            productId: productId,
            autoRenewProductId: autoRenewProductId,
            originalTransactionId: nil,
            autoRenewStatus: .on
        )
    }
}
