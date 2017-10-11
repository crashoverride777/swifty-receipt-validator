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
    
    // MARK: - Methods
    
    /// Fetch app store in app purchase receipt
    ///
    /// - result: Called when the fetching is finished. Will return an optional URL depending on success of fetching.
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

// MARK: - SKRequestDelegate

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

// MARK: - Print

private extension SwiftyReceiptObtainer {
    
    /// Overrides the default print method so it print statements only show when in DEBUG mode
    func print(_ items: Any...) {
        #if DEBUG
            Swift.print(items)
        #endif
    }
}
