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

private enum JSONObjectKey: String {
    case receiptData = "receipt-data"
    case password
}

/*
 SwiftyReceiptValidator
 
 An enum to manage in app purchase receipt validation.
 */
public enum SwiftyReceiptValidator {
    public typealias SwiftyReceiptValidatorResult = (Result<[String: AnyObject]>) -> Void
    
    // MARK: - Properties
    
    enum URLString: String {
        case appleSandbox    = "https://sandbox.itunes.apple.com/verifyReceipt"
        case appleProduction = "https://buy.itunes.apple.com/verifyReceipt"
    }
    
    public enum Result<T> {
        case success(data: T)
        case failure(code: Int?, error: ValidationError)
    }
    
    static var productIdentifier = ""
    
    private static let receiptObtainer = SwiftyReceiptObtainer()
    
    // MARK: - Methods
    
    /// Validate receipt
    ///
    /// - parameter productIdentifier: The product Identifier String for the product to validate.
    /// - parameter sharedSecret: The shared secret when using auto-subscriptions.
    /// - result handler: Called when the validation has completed. Will return the success state of the validation and an optional dictionary for further receipt validation if successfull.
    public static func start(withProductId productIdentifier: String, sharedSecret: String?, handler: @escaping SwiftyReceiptValidatorResult) {
        
        self.productIdentifier = productIdentifier
        
        receiptObtainer.fetch { receiptURL in
            guard let receiptURL = receiptURL else {
                handler(.failure(code: nil, error: .noReceiptFound))
                return
            }
            
            do {
                let receiptData = try Data(contentsOf: receiptURL)
                
                self.startValidation(withReceiptData: receiptData, sharedSecret: sharedSecret) { result in
                    DispatchQueue.main.async {
                        handler(result)
                    }
                }
            }
                
            catch let error {
                handler(.failure(code: nil, error: .other(error)))
            }
        }
    }
}

// MARK: - Start Receipt Validation

private extension SwiftyReceiptValidator {
    
    static func startValidation(withReceiptData receiptData: Data, sharedSecret: String?, handler: @escaping SwiftyReceiptValidatorResult) {
        
        // Prepare receipt
        let receipt = receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        // Prepare parameters
        var parameters = [
            JSONObjectKey.receiptData.rawValue: receipt
        ]
        
        if let sharedSecret = sharedSecret {
            parameters[JSONObjectKey.password.rawValue] = sharedSecret
        }
      
        // Start URL request to production server first, if it fails because in test environment try sandbox
        // This handles validation directily with apple. This is not the recommended way by apple as it is not secure.
        // It is still better than not doing any validation at all.
        // If you will use your own server than just will have to adjust this last bit of code to only send to your server and than connect to
        // apple production/sandbox for there.
        startURLSession(with: .appleProduction, parameters: parameters) { result in
           
            switch result {
                
            case .success(let data):
                handler(.success(data: data))
                
            case .failure(let code, let error):
                // Check if failed production request was due to a test receipt
                guard code == StatusCode.testReceipt.rawValue else {
                    handler(.failure(code: code, error: .other(error)))
                    return
                }
                
                // Handle request to sandbox server
                self.startURLSession(with: .appleSandbox, parameters: parameters) { result in
                    
                    switch result {
                    case .success(let data):
                        handler(.success(data: data))
                    case .failure(let code, let error):
                        handler(.failure(code: code, error: .other(error)))
                    }
                }
            }
        }
    }
}
