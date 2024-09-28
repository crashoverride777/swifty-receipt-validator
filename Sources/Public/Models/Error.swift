import Foundation

public enum SRVError: Error, Equatable, Sendable {
    case noReceiptFoundInBundle
    case invalidStatusCode(SRVStatusCode)
    case noReceiptFoundInResponse(SRVStatusCode)
    case bundleIdNotMatching(SRVStatusCode)
    case productIdNotMatching(SRVStatusCode)
    case subscriptioniOS6StyleExpired(SRVStatusCode?)
    case purchaseCancelled(SRVStatusCode)
    
    public var statusCode: SRVStatusCode? {
        switch self {
        case .noReceiptFoundInBundle:
            return nil
        case .invalidStatusCode(let statusCode):
            return statusCode
        case .noReceiptFoundInResponse(let statusCode):
            return statusCode
        case .bundleIdNotMatching(let statusCode):
            return statusCode
        case .productIdNotMatching(let statusCode):
            return statusCode
        case .subscriptioniOS6StyleExpired(let statusCode):
            return statusCode
        case .purchaseCancelled(let statusCode):
            return statusCode
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .noReceiptFoundInBundle:
            return "No receipt found in bundle."
        case .invalidStatusCode(let statusCode):
            return "Invalid status code \(statusCode.rawValue): \(statusCode.description)."
        case .noReceiptFoundInResponse:
            return "Receipt not found in response."
        case .bundleIdNotMatching:
            return "Bundle id not matching receipt."
        case .productIdNotMatching:
            return "Product id not matching receipt."
        case .subscriptioniOS6StyleExpired:
            return "iOS 6 style subscription expired."
        case .purchaseCancelled:
            return "Purchase has been cancelled."
        }
    }
}
