//
//  PurchaseRequest.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 19/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation

public struct SRVPurchaseRequest {
    let productId: String
    let sharedSecret: String?
    
    /// SwiftyReceiptValidatorSubscriptionRequest Init
    ///
    /// - parameter productId: The product id of the purchase to validate.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    public init(productId: String, sharedSecret: String?) {
        self.productId = productId
        self.sharedSecret = sharedSecret
    }
}
