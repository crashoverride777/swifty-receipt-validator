import Foundation
import StoreKit

extension SKRequest {
    convenience init(id: String = "123") {
        self.init()
    }
    
    static func mock() -> SKRequest {
        SKRequest()
    }
}
