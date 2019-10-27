//
//  SRVAutoRenewStatus.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 17/10/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public enum SRVAutoRenewStatus: String, Codable {
    // Customer has turned off automatic renewal for their subscription
    case off = "0"
    // Subscription will renew at the end of the current subscription period
    case on = "1"
}
