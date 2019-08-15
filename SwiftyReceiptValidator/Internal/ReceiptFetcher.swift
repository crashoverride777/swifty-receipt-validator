//
//  ReceiptFetcher.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
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

import StoreKit

#warning("This triggers login prompt if it refreshes, how can we avoid this?")
final class SwiftyReceiptFetcher: NSObject {    
    typealias ResultHandler = (Result<URL, SwiftyReceiptValidatorError>) -> Void
    
    // MARK: - Properties
    
    private var receiptHandler: ResultHandler?
    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    private var hasReceipt: Bool {
        guard let path = receiptURL?.path else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: path)
    }
    
    // MARK: - Methods
    
    func fetch(handler: @escaping ResultHandler) {
        receiptHandler = handler
        
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            receiptRefreshRequest?.delegate = self
            receiptRefreshRequest?.start()
            return
        }
        
        clean()
        handler(.success(receiptURL))
    }
    
    private func clean() {
        receiptHandler = nil
        receiptRefreshRequest = nil
    }
}

// MARK: - SKRequestDelegate

extension SwiftyReceiptFetcher: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let receiptURL = receiptURL else {
            receiptHandler?(.failure(.noReceiptFound))
            return
        }
        
        receiptHandler?(.success(receiptURL))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error)
        receiptHandler?(.failure(.other(error)))
        clean()
    }
}
