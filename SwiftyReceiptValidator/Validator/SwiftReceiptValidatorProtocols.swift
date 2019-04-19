//
//  SwiftReceiptValidatorProtocols.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public typealias SwiftyReceiptValidators = ReceiptDefaultValidator & ReceiptPurchaseValidator & ReceiptSubscriptionValidator

public protocol ReceiptDefaultValidator: class {
    func validate(_ response: SwiftyReceiptResponse, handler: @escaping SwiftyReceiptValidatorResultHandler)
}

public protocol ReceiptPurchaseValidator: class {
    func validatePurchase(forProductId productId: String,
                          in response: SwiftyReceiptResponse,
                          handler: @escaping SwiftyReceiptValidatorResultHandler)
}

public protocol ReceiptSubscriptionValidator: class {
    func validateSubscription(in response: SwiftyReceiptResponse,
                              handler: @escaping (SwiftyReceiptValidatorResult<(SwiftyReceiptResponse)>) -> Void)
}
