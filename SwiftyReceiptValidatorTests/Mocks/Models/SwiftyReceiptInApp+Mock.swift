//
//  SwiftyReceiptInApp+Mock.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 27/08/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation
@testable import SwiftyReceiptValidator

extension SwiftyReceiptInApp {
    
    static func mock(isTrialPeriod: String = "false", isInIntroOfferPeriod: String = "false") -> SwiftyReceiptInApp {
        let inApp = SwiftyReceiptResponse.fake(.subscription).receipt!.inApp.first!
        return SwiftyReceiptInApp(
            quantity: inApp.quantity,
            productId: inApp.productId,
            transactionId: inApp.transactionId,
            originalTransactionId: inApp.originalTransactionId,
            purchaseDate: inApp.purchaseDate,
            originalPurchaseDate: inApp.originalPurchaseDate,
            expiresDate: inApp.expiresDate,
            expirationIntent: inApp.expirationIntent,
            isInBillingRetryPeriod: inApp.isInBillingRetryPeriod,
            isTrialPeriod: isTrialPeriod,
            isInIntroOfferPeriod: isInIntroOfferPeriod,
            autoRenewStatus: inApp.autoRenewStatus,
            cancellationDate: inApp.cancellationDate,
            cancellationReason: inApp.cancellationReason,
            appItemId: inApp.appItemId,
            versionExternalIdentifier: inApp.versionExternalIdentifier,
            webOrderLineItemId: inApp.webOrderLineItemId
        )
    }
}
