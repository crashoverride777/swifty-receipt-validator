//
//  SRVPendingRenewalInfo.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 27/02/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public struct SRVPendingRenewalInfo: Codable {
    public let productId: String?
    public let autoRenewProductId: String?
    public let originalTransactionId: String?
    public let autoRenewStatus: AutoRenewStatus?
}

public extension SRVPendingRenewalInfo {
    
    enum AutoRenewStatus: String, Codable {
        // Customer has turned off automatic renewal for their subscription
        case off = "0"
        // Subscription will renew at the end of the current subscription period
        case on = "1"
    }
}
