import Foundation

public extension SRVReceipt {
    static func mock(
        receiptType: String = "subscription",
        adamId: Int = 1,
        appItemId: Int = 2,
        bundleId: String = "test.com",
        applicationVersion: String = "1.0",
        originalApplicationVersion: String = "1.0",
        downloadId: Int? = 2,
        versionExternalIdentifier: Int = 3,
        receiptCreationDate: Date = Date().addingTimeInterval(-20000),
        expirationDate: Date? = Date().addingTimeInterval(20000),
        requestDate: Date = Date().addingTimeInterval(-20005),
        originalPurchaseDate: Date = Date().addingTimeInterval(-30000),
        inApp: [SRVReceiptInApp] = [.mock()]) -> SRVReceipt {
        SRVReceipt(
            receiptType: receiptType,
            adamId: adamId,
            appItemId: appItemId,
            bundleId: bundleId,
            applicationVersion: applicationVersion,
            originalApplicationVersion: originalApplicationVersion,
            downloadId: downloadId,
            versionExternalIdentifier: versionExternalIdentifier,
            receiptCreationDate: receiptCreationDate,
            expirationDate: expirationDate,
            requestDate: requestDate,
            originalPurchaseDate: originalPurchaseDate,
            inApp: inApp
        )
    }
}
