
//  Created by Dominik on 10/07/2016.

//    The MIT License (MIT)
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

//    v1.1

/*
    Abstract:
    A Singleton class to manage in app purchase receipt fetching.
*/

import StoreKit

final class AppStoreReceiptObtainer: NSObject {
    
    // MARK: - Static Properties
    
    /// Shared instance
    static let sharedInstance = AppStoreReceiptObtainer()
    
    // MARK: - Properties
    
    fileprivate let receiptURL = Bundle.main.appStoreReceiptURL
    fileprivate var completionHandler: ((NSURL?) -> ())?
    
    fileprivate var receiptExistsAtPath: Bool {
        guard let path = receiptURL?.path, FileManager.default.fileExists(atPath: path) else { return false }
        return true
    }
    
    // MARK: - Init
    
    fileprivate override init () {
        super.init()
    }
    
    // MARK: - Methods
    
    /// Fetch app store receipt
    func fetch(withCompletionHandler completionHandler: @escaping (NSURL?) -> ()) {
        self.completionHandler = completionHandler
        
        guard receiptExistsAtPath else {
            print("Requesting a new receipt")
            let request = SKReceiptRefreshRequest(receiptProperties: nil)
            request.delegate = self
            request.start()
            return
        }
        
        print("Receipt found")
        self.completionHandler?(receiptURL as NSURL?)
    }
}

// SKRequestDelegate
extension AppStoreReceiptObtainer: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        print("Receipt request did finish")
        
        guard receiptExistsAtPath else {
            print("Could not obtainin the receipt from the receipt request, maybe the user did not successfully enter it's credentials")
            completionHandler?(nil)
            return
        }
        
        print("Newly created receipt found")
        completionHandler?(receiptURL as NSURL?)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
        completionHandler?(nil)
    }
}
