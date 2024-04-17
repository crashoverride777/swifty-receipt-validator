import Foundation

public extension SRVReceiptInApp {
    static func mock(
        quantity: String = "1",
        productId: String = UUID().uuidString,
        transactionId: String = UUID().uuidString,
        originalTransactionId: String = UUID().uuidString,
        purchaseDate: Date = Date().addingTimeInterval(-20000),
        originalPurchaseDate: Date = Date().addingTimeInterval(-20005),
        expiresDate: Date? = Date().addingTimeInterval(20000),
        expirationIntent: ExpirationIntent? = nil,
        isInBillingRetryPeriod: ExpirationRetry? = nil,
        isTrialPeriod: String? = "false",
        isInIntroOfferPeriod: String? = "false",
        cancellationDate: Date? = nil,
        cancellationReason: CancellationReason? = nil,
        appItemId: String? = nil,
        versionExternalIdentifier: String? = nil,
        webOrderLineItemId: String? = nil,
        autoRenewStatus: SRVAutoRenewStatus? = .on,
        autoRenewProductId: String? = nil,
        priceConsentStatus: PriceConsentStatus? = nil) -> SRVReceiptInApp {
        SRVReceiptInApp(
            quantity: quantity,
            productId: productId,
            transactionId: transactionId,
            originalTransactionId: originalTransactionId,
            purchaseDate: purchaseDate,
            originalPurchaseDate: originalPurchaseDate,
            expiresDate: expiresDate,
            expirationIntent: expirationIntent,
            isInBillingRetryPeriod: isInBillingRetryPeriod,
            isTrialPeriod: isTrialPeriod,
            isInIntroOfferPeriod: isInIntroOfferPeriod,
            cancellationDate: cancellationDate,
            cancellationReason: cancellationReason,
            appItemId: appItemId,
            versionExternalIdentifier: versionExternalIdentifier,
            webOrderLineItemId: webOrderLineItemId,
            autoRenewStatus: autoRenewStatus,
            autoRenewProductId: autoRenewProductId,
            priceConsentStatus: priceConsentStatus
        )
    }
}
