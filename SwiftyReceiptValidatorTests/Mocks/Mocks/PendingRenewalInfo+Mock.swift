//
//  PendingRenewalInfo+Mock.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 25/11/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public extension SRVPendingRenewalInfo {
    
    static func mock(
        productId: String? = UUID().uuidString,
        autoRenewProductId: String? = UUID().uuidString,
        originalTransactionId: String? = UUID().uuidString,
        autoRenewStatus: SRVAutoRenewStatus? = .on) -> SRVPendingRenewalInfo {
        SRVPendingRenewalInfo(
            productId: productId,
            autoRenewProductId: autoRenewProductId,
            originalTransactionId: originalTransactionId,
            autoRenewStatus: autoRenewStatus
        )
    }
}
