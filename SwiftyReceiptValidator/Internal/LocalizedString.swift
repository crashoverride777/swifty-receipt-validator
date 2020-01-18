//
//  LocalizedString.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 19/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import Foundation

enum LocalizedString {
    enum Error {
        static let url = localized("ErrorURL", comment: "Invalid URL")
        static let data = localized("ErrorData", comment: "Invalid data")
        
        static let invalidStatusCode = localized("ErrorInvalidStatusCode", comment: "Invalid status code")
        static let noReceiptFound = localized("ErrorNoReceiptFound", comment: "No receipt found on device")
        static let noReceiptFoundInResponse = localized("ErrorNoReceiptFoundInResponse", comment: "No receipt found in server response")
        static let bundleIdNotMatching = localized("ErrorBundleIdNotMatching", comment: "Bundle id is not matching receipt")
        static let productIdNotMatching = localized("ErrorProductIdNotMatching", comment: "Product id is not matching with receipt")
        static let noValidSubscription = localized("ErrorNoValidSubscription", comment: "No active subscription found")
        static let cancelled = localized("ErrorCancelled", comment: "Cancelled")
    }
}

// MARK: - Get Localized String

private extension LocalizedString {
    
    static func localized(_ text: String, comment: String) -> String {
        NSLocalizedString(
            text, tableName: nil,
            bundle: Bundle(for: SwiftyReceiptValidator.self),
            value: "",
            comment: comment
        )
    }
}
