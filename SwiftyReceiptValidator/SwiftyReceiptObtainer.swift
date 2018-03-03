//
//  SwiftyReceiptObtainer.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik on 09/08/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

import StoreKit

final class SwiftyReceiptObtainer: NSObject {
    
    // MARK: - Properties
    
    private let receiptURL = Bundle.main.appStoreReceiptURL
    private var handler: ((URL?) -> Void)?
    
    private var isReceiptExisting: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
    
    // MARK: - Fetch
    
    func fetch(handler: @escaping (URL?) -> Void) {
        self.handler = handler
        
        guard isReceiptExisting else {
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
        guard isReceiptExisting else {
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
