//    The MIT License (MIT)
//
//    Copyright (c) 2016-2017 Dominik Ringler
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

/*
 Swifty Receipt Obtainer
 
 Singleton class to manage in app purchase receipt fetching.
 */
final class SwiftyReceiptObtainer: NSObject {
    
    // MARK: - Static Properties
    
    /// Shared instance
    static let shared = SwiftyReceiptObtainer()
    
    // MARK: - Properties
    
    /// Receipt url
    fileprivate let receiptURL = Bundle.main.appStoreReceiptURL
    
    /// Completion handler
    fileprivate var handler: ((URL?) -> ())?
    
    /// Check if receipt exists at patch
    fileprivate var isReceiptExistsAtPath: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
    
    // MARK: - Init
    
    /// Init
    private override init () { }
    
    // MARK: - Methods
    
    /// Fetch app store in app purchase receipt
    ///
    /// - result: Called when the fetching is finished. Will return an optional URL depending on success of fetching.
    func fetch(handler: @escaping (URL?) -> ()) {
        self.handler = handler
        
        guard isReceiptExistsAtPath else {
            print("Requesting a new receipt")
            let request = SKReceiptRefreshRequest(receiptProperties: nil)
            request.delegate = self
            request.start()
            return
        }
        
        print("Receipt found")
        self.handler?(receiptURL)
    }
}

// MARK: - SKRequestDelegate

// SKRequestDelegate
extension SwiftyReceiptObtainer: SKRequestDelegate {
    
    /// Request did finish
    func requestDidFinish(_ request: SKRequest) {
        print("Receipt request did finish")
        
        guard isReceiptExistsAtPath else {
            print("Could not obtainin the receipt from the receipt request, maybe the user did not successfully enter it's credentials")
            handler?(nil)
            return
        }
        
        print("Newly created receipt found")
        handler?(receiptURL)
    }
    
    /// Request did fail with error
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
        handler?(nil)
    }
}
