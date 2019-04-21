//
//  LocalizedString.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 19/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2016-2019 Dominik Ringler
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

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

private final class BundleClass { }
private extension LocalizedString {
    
    static func localized(_ text: String, comment: String) -> String {
        return NSLocalizedString(text, tableName: nil,
                                 bundle: Bundle(for: BundleClass.self),
                                 value: "",
                                 comment: comment)
    }
}
