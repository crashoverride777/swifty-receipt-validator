//
//  SubscriptionValidationResponse+Mock.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 25/11/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public extension SRVSubscriptionValidationResponse {
    
    static func mock(
        validReceipts: [SRVReceiptInApp] = [.mock()],
        receiptResponse: SRVReceiptResponse = .mock()) -> SRVSubscriptionValidationResponse {
        SRVSubscriptionValidationResponse(
            validReceipts: validReceipts,
            receiptResponse: receiptResponse
        )
    }
}
