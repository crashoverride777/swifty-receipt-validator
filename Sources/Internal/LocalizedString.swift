//
//  LocalizedString.swift
//  
//
//  Created by Dominik Ringler on 26/09/2020.
//

import Foundation

enum LocalizedString {

    enum Error {
        static let noReceiptFoundInBundle = NSLocalizedString("NoReceiptFoundInBundle", comment: "No receipt found in bundle.")
        static let noReceiptFoundInResponse = NSLocalizedString("NoReceiptFoundInResponse", comment: "Receipt not found in response.")
        static let bundleIdNotMatching = NSLocalizedString("BundleIdNotMatching", comment: "Bundle id not matching receipt.")
        static let productIdNotMatching = NSLocalizedString("ProductIdNotMatching", comment: "Product id not matching receipt.")
        static let subscriptioniOS6StyleExpired = NSLocalizedString("SubscriptioniOS6StyleExpired", comment: "iOS 6 style subscription expired.")
        static let purchaseCancelled = NSLocalizedString("PurchaseCancelled", comment: "Purchase has been cancelled.")


        static func invalidStatusCode(_ code: Int) -> String {
            localized("InvalidStatusCode", comment: "Invalid status code", argument: code)
        }
    }
}

private extension LocalizedString {

    static func localized(_ text: String, comment: String, argument: CVarArg? = nil) -> String {
        let localizedString = NSLocalizedString(text, bundle: .module, comment: comment)

        // If argument is not set return localized string
        guard let argument = argument else {
            return localizedString
        }

        // Return localized string with both arguments
        return String(format: localizedString, argument)
    }
}
