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
    }
}

// MARK: - Get Localized String

private final class BundleClass { }
private extension LocalizedString {
    
    static func localized(_ text: String, comment: String) -> String {
        return NSLocalizedString(text, tableName: nil,
                                 bundle: Bundle(for: BundleClass.self),
                                 value: "",
                                 comment: comment)
    }
}
