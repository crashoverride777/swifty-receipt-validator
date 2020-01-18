//
//  SRVSubscriptionValidationResponse.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 17/10/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public struct SRVSubscriptionValidationResponse: Equatable {
    public let validReceipts: [SRVReceiptInApp]
    public let pendingRenewalInfo: [SRVPendingRenewalInfo]?
}
