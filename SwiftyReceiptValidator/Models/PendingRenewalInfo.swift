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
    public let autoRenewStatus: SRVAutoRenewStatus?
}
