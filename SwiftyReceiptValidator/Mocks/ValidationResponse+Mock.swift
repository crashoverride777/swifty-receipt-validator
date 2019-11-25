//
//  ValidationResponse+Mock.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 25/11/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

extension SRVSubscriptionValidationResponse {
    
    public static func mock(
        validReceipts: [SRVReceiptInApp] = [.mock()],
        pendingRenewalInfo: [SRVPendingRenewalInfo] = [.mock()]) -> SRVSubscriptionValidationResponse {
        SRVSubscriptionValidationResponse(
            validReceipts: validReceipts,
            pendingRenewalInfo: pendingRenewalInfo
        )
    }
}
