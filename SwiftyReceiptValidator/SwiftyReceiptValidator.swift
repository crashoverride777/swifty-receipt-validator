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

/// Request URLs
private enum RequestURL: String {
    case appleSandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
    case appleProduction = "https://buy.itunes.apple.com/verifyReceipt"
}

/// HTTP Methid
private enum HTTPMethod: String {
    case post = "POST"
}

/// JSON Object Keys
private enum JSONObjectKey: String {
    case receiptData = "receipt-data" // The base64 encoded receipt data.
    case password // Only used for receipts that contain auto-renewable subscriptions. Your app’s shared secret (a hexadecimal string).
}

/*
 SwiftyReceiptValidator
 
 An enum to manage in app purchase receipt validation.
 */
private let validationErrorString = "Receipt validation failed: "

public enum SwiftyReceiptValidator {
    
    // MARK: - Properties
    
    fileprivate static var productIdentifier = ""
    
    // MARK: - Methods
    
    /// Validate receipt
    ///
    /// - parameter productID: The product ID String for the product to validate.
    /// - parameter sharedSecret: The shared secret when using auto-subscriptions.
    /// - result handler: Called when the validation has completed. Will return the success state of the validation and an optional dictionary for further receipt validation if successfull.
    public static func validate(forIdentifier productIdentifier: String, sharedSecret: String?, handler: @escaping (Bool, [String: AnyObject]?) -> ()) {
        
        self.productIdentifier = productIdentifier
        
        SwiftyReceiptObtainer.shared.fetch { receiptURL in
            guard let validReceiptURL = receiptURL else {
                print("Receipt fetch error")
                validationFailHandler(handler)
                return
            }
            
            self.startValidation(forURL: validReceiptURL, sharedSecret: sharedSecret) { (success, json) in
                DispatchQueue.main.async {
                    handler(success, json)
                }
            }
        }
    }
}

// MARK: - Start Receipt Validation

private extension SwiftyReceiptValidator {
    
    /// Start receipt validation
    static func startValidation(forURL url: URL, sharedSecret: String?, handler: @escaping (Bool, [String: AnyObject]?) -> ()) {
        print("Starting receipt validation")
        
        // Check for valid receipt content for url
        
        // Receipt data
        var receipt: Data?
        
        do {
            receipt = try Data(contentsOf: url)
        }
            
        catch let error as NSError {
            print(error.localizedDescription)
            validationFailHandler(handler)
            return
        }
        
        // Prepare payload
        let receiptData = receipt?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        var payload = [JSONObjectKey.receiptData.rawValue: receiptData]
        if let sharedSecret = sharedSecret {
            payload[JSONObjectKey.password.rawValue] = sharedSecret
        }
        
        var receiptPayloadData: Data?
        
        do {
            receiptPayloadData = try JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions(rawValue: 0))
        }
            
        catch let error as NSError {
            print(error.localizedDescription)
            validationFailHandler(handler)
        }
        
        guard let payloadData = receiptPayloadData else {
            print(validationErrorString + "Payload data error")
            validationFailHandler(handler)
            return
        }
        
        /// URL request to production server first, if it fails because in test environment try sandbox
        /// This handles validation directily with apple. This is not the recommended way by apple as it is not secure.
        /// It is still better than not doing any validation at all.
        /// If you will use your own server than just will have to adjust this last bit of code to only send to your server and than connect to
        /// apple production/sandbox for there.
        handleRequest(forURL: RequestURL.appleProduction.rawValue, data: payloadData) { (isSuccess, status, response) in
            guard !isSuccess else {
                print("Receipt validation passed in production mode, unlocking product(s)")
                DispatchQueue.main.async {
                    handler(true, response)
                }
                
                return
            }
            
            /// Check if failed production request was due to a test receipt
            guard status == StatusCode.testReceipt.rawValue else {
                print(validationErrorString + "Status = \(status ?? StatusCode.unknown.rawValue)")
                validationFailHandler(handler)
                return
            }
            
            print(validationErrorString + "Production url used in sandbox mode, trying sandbox url...")
            
            /// Handle request to sandbox server
            self.handleRequest(forURL: RequestURL.appleSandbox.rawValue, data: payloadData) { (isSuccess, status, response) in
                guard isSuccess else {
                    print(validationErrorString + "Status = \(status ?? StatusCode.unknown.rawValue)")
                    validationFailHandler(handler)
                    return
                }
                
                print("Receipt validation passed in sandbox mode, unlocking product(s)")
                DispatchQueue.main.async {
                    handler(true, response)
                }
            }
        }
    }
    
    /// Did fail validation handler
    static func validationFailHandler(_ handler: @escaping (Bool, [String: AnyObject]?) -> ()) {
        DispatchQueue.main.async {
            handler(false, nil)
        }
    }
}


// MARK: - Handle URL Request

private let urlRequestString = "URL request - "
private typealias RequestHandler = (_ isSuccess: Bool, _ status: Int?, _ response: [String: AnyObject]?) -> ()

private extension SwiftyReceiptValidator {
    
    /// Handle receipt request
    static func handleRequest(forURL url: String, data: Data, handler: @escaping RequestHandler) {
        
        // Request url
        guard let requestURL = URL(string: url) else {
            print(validationErrorString + "Request url not found")
            requestFailHandler(handler)
            return
        }
        // Request
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            /// URL request error
            if let error = error {
                print(validationErrorString + urlRequestString + error.localizedDescription)
                requestFailHandler(handler)
                return
            }
            
            /// URL request data error
            guard let data = data else {
                print(validationErrorString + urlRequestString + "Data error")
                requestFailHandler(handler)
                return
            }
            
            /// JSON
            var json: [String: AnyObject]?
            
            do {
                json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String : AnyObject]
            }
            catch let error as NSError {
                print(validationErrorString + urlRequestString + error.localizedDescription)
                requestFailHandler(handler)
                return
            }
            
            /// Parse json
            guard let parseJSON = json else {
                print(validationErrorString + urlRequestString + "JSON parse error")
                requestFailHandler(handler)
                return
            }
            
            /// Check for receipt status in json
            guard let status = parseJSON[ResponseKey.status.rawValue] as? Int else {
                print(validationErrorString + urlRequestString + "Receipt status not found in json response")
                requestFailHandler(handler)
                return
            }
            
            /// Check receipt status is valid
            guard status == StatusCode.valid.rawValue else {
                print(validationErrorString + urlRequestString + "Invalid receipt status in json response = \(status)")
                DispatchQueue.main.async {
                    handler(false, status, nil)
                }
                
                return
            }
            
            print("Valid receipt status in json reponse: \(status)")
            
            /// Handle additional security checks
            
            /// Check receipt send for verification exists in json response
            guard let receipt = parseJSON[ResponseKey.receipt.rawValue] else {
                print(validationErrorString + urlRequestString + "Could not find receipt send for validation in json reponse")
                requestFailHandler(handler)
                return
            }
            
            print(urlRequestString + "Valid receipt in json reponse = \(receipt)")
            
            /// Check receipt contains correct bundle and product id for app
            guard self.isAppBundleIDMatching(withReceipt: receipt) && self.isTransactionProductIDMatching(withReceipt: receipt) else {
                requestFailHandler(handler)
                return
            }
            
            // standard Validation successfull
            print(urlRequestString + "Default receipt verification successful")
            DispatchQueue.main.async {
                handler(true, nil, parseJSON)
            }
        }
        
        .resume()
    }
    
    /// Did fail request handler
    static func requestFailHandler(_ handler: @escaping RequestHandler) {
        DispatchQueue.main.async {
            handler(false, nil, nil)
        }
    }
}

// MARK: - Receipt Validation Basic Checks

private extension SwiftyReceiptValidator {
    
    /// Check if app bundle ID is matching with receipt bundle ID
    static func isAppBundleIDMatching(withReceipt receipt: AnyObject) -> Bool {
        let receiptBundleID = receipt[InfoKey.bundle_id.rawValue] as? String ?? "NoReceiptBundleID"
        let appBundleID = Bundle.main.bundleIdentifier ?? "NoAppBundleID"
        
        guard receiptBundleID == appBundleID else {
            print(validationErrorString + urlRequestString + "App bundle id: \(appBundleID) not matching with receipt bundle id: \(receiptBundleID)")
            return false
        }
        
        return true
    }
    
    /// Check if transaction product ID is matching with receipt product ID
    static func isTransactionProductIDMatching(withReceipt receipt: AnyObject) -> Bool {
        guard let inApp = receipt[InfoKey.in_app.rawValue] as? [AnyObject] else {
            print(validationErrorString + urlRequestString + "Could not find receipt in app array in json response")
            return false
        }
        
        var receiptProductID = ""
        
        for receiptInApp in inApp {
            receiptProductID = receiptInApp[InfoKey.InApp.product_id.rawValue] as? String ?? "NoReceiptProductID"
            if receiptProductID == productIdentifier {
                return true
            }
        }
        
        print(validationErrorString + urlRequestString + "Transaction product ID \(productIdentifier) not matching with receipt product id = \(receiptProductID)")
        return false
    }
}

// MARK: - Receipt Obtainer

private final class SwiftyReceiptObtainer: NSObject {
    
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

// MARK: - Status Codes and Keys

extension SwiftyReceiptValidator {
    
    /// Status Code
    public enum StatusCode: Int {
        case unknown = -2 // No decodable status
        case none = -1 // No status returned
        case valid = 0 // Valid status
        case jsonNotReadable = 21000 // The App Store could not read the JSON object you provided.
        case malformedOrMissingData = 21002 // The data in the receipt-data property was malformed or missing.
        case receiptCouldNotBeAuthenticated = 21003 // The receipt could not be authenticated.
        case sharedSecretNotMatching = 21004 // The shared secret you provided does not match the shared secret on file for your account.
        // Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.
        case receiptServerUnavailable = 21005 // The receipt server is currently not available.
        case subscriptionExpired = 21006 // This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response.
        // Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.
        case testReceipt = 21007 //  This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.
        case productionEnvironment = 21008 // This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.
    }
    
    /// Response Key
    public enum ResponseKey: String {
        case status // See ReceiptStatusCode
        // For iOS 6 style transaction receipts, the status code reflects the status of the specific transaction’s receipt.
        // For iOS 7 style app receipts, the status code is reflects the status of the app receipt as a whole. For example, if you send a valid app receipt that contains an expired subscription, the response is 0 because the receipt as a whole is valid.
        case receipt // A JSON representation of the receipt that was sent for verification. For information about keys found in a receipt, see Receipt Fields.
        case latest_receipt // Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions. The base-64 encoded transaction receipt for the most recent renewal.
        case latest_receipt_info // Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions. The JSON representation of the receipt for the most recent renewal.
    }
    
    /// Receipt Info Field
    public enum InfoKey: String {
        case bundle_id // This corresponds to the value of CFBundleIdentifier in the Info.plist file.
        case application_version // This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist.
        case original_application_version // The version of the app that was originally purchased. This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist file when the purchase was originally made.
        case creation_date // The date when the app receipt was created.
        case expiration_date // The date that the app receipt expires. This key is present only for apps purchased through the Volume Purchase Program.
        case in_app // The receipt for an in-app purchase. This will be an array of dictionaries with all your individial receipts. See below
        
        enum InApp: String {
            
            case quantity // The number of items purchased. This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
            case product_id // The product identifier of the item that was purchased. This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
            case transaction_id // The transaction identifier of the item that was purchased. This value corresponds to the transaction’s transactionIdentifier property.
            case original_transaction_id // For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier. This value corresponds to the original transaction’s transactionIdentifier property. All receipts in a chain of renewals for an auto-renewable subscription have the same value for this field.
            case purchase_date // The date and time that the item was purchased. This value corresponds to the transaction’s transactionDate property.
            case original_purchase_date // For a transaction that restores a previous transaction, the date of the original transaction. This value corresponds to the original transaction’s transactionDate property. In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renewed.
            case expires_date // The expiration date for the subscription, expressed as the number of milliseconds since January 1, 1970, 00:00:00 GMT. This key is only present for auto-renewable subscription receipts.
            case cancellation_date // For a transaction that was canceled by Apple customer support, the time and date of the cancellation. Treat a canceled receipt the same as if no purchase had ever been made.
            #if os(iOS) || os(tvOS)
            case app_item_id // A string that the App Store uses to uniquely identify the application that created the transaction. If your server supports multiple applications, you can use this value to differentiate between them. Apps are assigned an identifier only in the production environment, so this key is not present for receipts created in the test environment. This field is not present for Mac apps. See also Bundle Identifier.
            #endif
            case version_external_identifier // An arbitrary number that uniquely identifies a revision of your application. This key is not present for receipts created in the test environment.
            case web_order_line_item_id // The primary key for identifying subscription purchases.
        }
    }
}
