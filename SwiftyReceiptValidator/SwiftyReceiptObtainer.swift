//
//  SwiftyReceiptObtainer.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

//    The MIT License (MIT)
//
//    Copyright (c) 2016-2018 Dominik Ringler
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import StoreKit

final class SwiftyReceiptObtainer: NSObject {
    
    // MARK: - Properties
    
    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var handler: ((URL?) -> Void)?
    
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
    
    // MARK: - Fetch
    
    func fetch(handler: @escaping (URL?) -> Void) {
        self.handler = handler
        
        guard hasReceipt else {
            let request = SKReceiptRefreshRequest(receiptProperties: nil)
            request.delegate = self
            request.start()
            return
        }
        
        self.handler?(receiptURL)
    }
}

// MARK: - SK Request Delegate

extension SwiftyReceiptObtainer: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        guard hasReceipt else {
            handler?(nil)
            return
        }
        
        handler?(receiptURL)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
        handler?(nil)
    }
}
