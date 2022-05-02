import Foundation

public struct SRVReceipt: Codable, Equatable {
    // The type of receipt
    public let receiptType: String
    // The adam id of the receipt
    public let adamId: Int
    // A string that the App Store uses to uniquely identify the application that created the transaction. If your server supports multiple applications, you can use this value to differentiate between them. Apps are assigned an identifier only in the production environment, so this key is not present for receipts created in the test environment. This field is not present for Mac apps. See also Bundle Identifier.
    public let appItemId: Int
    // This corresponds to the value of CFBundleIdentifier in the Info.plist file.
    public let bundleId: String
    // This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist.
    public let applicationVersion: String
    // The version of the app that was originally purchased. This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist file when the purchase was originally made.
    public let originalApplicationVersion: String
    // The download id of the receipt
    // NOTE: Optional due to https://developer.apple.com/forums/thread/658179
    public let downloadId: Int?
    // An arbitrary number that uniquely identifies a revision of your application. This key is not present for receipts created in the test environment.
    public let versionExternalIdentifier: Int
    // The date when the receipt was created
    public let receiptCreationDate: Date
    // The date when the receipt expires
    public let expirationDate: Date?
    // The date when the receipt was requested
    public let requestDate: Date
    // The original purchase date
    public let originalPurchaseDate: Date
    // Collection of in app receipts
    public let inApp: [SRVReceiptInApp]
}
