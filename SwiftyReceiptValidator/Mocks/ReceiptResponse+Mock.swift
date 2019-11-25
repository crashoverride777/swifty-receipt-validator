//
//  ReceiptResponse+Mock.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 25/11/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

extension SRVReceiptResponse {
    
    public static func mock(
        status: StatusCode = .valid,
        receipt: SRVReceipt? = .mock(),
        latestReceipt: Data? = nil,
        latestReceiptInfo: [SRVReceiptInApp]? = [.mock()],
        pendingRenewalInfo: [SRVPendingRenewalInfo]? = [.mock()],
        environment: String? = nil) -> SRVReceiptResponse {
        SRVReceiptResponse(
            status: status,
            receipt: receipt,
            latestReceipt: latestReceipt,
            latestReceiptInfo: latestReceiptInfo,
            pendingRenewalInfo: pendingRenewalInfo,
            environment: environment
        )
    }
}
