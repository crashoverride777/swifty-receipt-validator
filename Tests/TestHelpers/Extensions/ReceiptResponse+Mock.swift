import Foundation
@testable import SwiftyReceiptValidator

extension SRVReceiptResponse {
    
    enum JSONType: String {
        case invalid             = "ReceiptResponseInvalidFormat"
        case subscription        = "ReceiptResponseValidSubscription"
        case subscriptionExpired = "ReceiptResponseSubscriptionExpired"
        case sandbox             = "ReceiptResponseSandbox"
        case noDownloadID        = "ReceiptResponseMissingDownloadID"
    }
    
    static func mock(_ type: JSONType) -> [String: Any] {
        guard let path = Bundle.module.path(forResource: type.rawValue, ofType: "json") else {
            fatalError("Invalid path to JSON file in bundle")
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: [])
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                fatalError("Invalid jsob object")
            }
            return dictionary
        } catch {
            fatalError("SwiftyReceiptResponse fake error \(error)")
        }
    }
    
    static func mock(from dictionary: [String: Any]) -> SRVReceiptResponse {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let decoder: JSONDecoder = .receiptResponse
            let receiptResponse = try decoder.decode(SRVReceiptResponse.self, from: data)
            return receiptResponse
        } catch {
            fatalError("SwiftyReceiptResponse fake error \(error)")
        }
    }
}
