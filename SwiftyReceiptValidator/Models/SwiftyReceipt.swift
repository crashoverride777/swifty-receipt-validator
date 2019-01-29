//
//  SwiftyReceipt.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 29/01/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

public struct SwiftyReceipt: Codable {
    // The type of receipt
    let receiptType: String
    // The adam id of the receipt
    let adamId: Int
    // A string that the App Store uses to uniquely identify the application that created the transaction. If your server supports multiple applications, you can use this value to differentiate between them. Apps are assigned an identifier only in the production environment, so this key is not present for receipts created in the test environment. This field is not present for Mac apps. See also Bundle Identifier.
    let appItemId: Int
    // This corresponds to the value of CFBundleIdentifier in the Info.plist file.
    let bundleId: String
    // This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist.
    let applicationVersion: String
    // The version of the app that was originally purchased. This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist file when the purchase was originally made.
    let originalApplicationVersion: String
    // The download id of the receipt
    let downloadId: Int
    // An arbitrary number that uniquely identifies a revision of your application. This key is not present for receipts created in the test environment.
    let versionExternalIdentifier: Int
    // The date when the receipt was created
    let receiptCreationDate: Date
    let receiptCreationDateMs: String
    let receiptCreationDatePst: Date
    // The date when the receipt was requested
    let requestDate: Date
    let requestDateMs: String
    let requestDatePst: Date
    // The original purchase date
    let originalPurchaseDate: Date
    let originalPurchaseDateMs: String
    let originalPurchaseDatePst: Date
    // Collection of in app receipts
    let inApp: [SwiftyReceiptInApp]
}
