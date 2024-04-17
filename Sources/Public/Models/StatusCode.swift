import Foundation

public enum SRVStatusCode: Int, Codable {
    case unknown = -1
    case valid = 0
    case jsonNotReadable = 21000
    case malformedOrMissingData = 21002
    case receiptCouldNotBeAuthenticated = 21003
    case sharedSecretNotMatching = 21004
    case receiptServerUnavailable = 21005
    case subscriptioniOS6StyleExpired = 21006
    case testReceipt = 21007
    case productionEnvironment = 21008
    case receiptCouldNotBeAuthorized = 21010
    // Codes 21100-21199 = Internal data access error.
    case internalDataAccessError = 21100
    
    public init(from decoder: Decoder) throws {
        self = try SRVStatusCode(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .internalDataAccessError
    }
}

// MARK: - Computed

public extension SRVStatusCode {
    var isValid: Bool {
        switch self {
        case .valid, .subscriptioniOS6StyleExpired:
            return true
        default:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .unknown:
            return "No decodable status"
        case .valid:
            return "Valid status"
        case .jsonNotReadable:
            return "The App Store could not read the JSON object you provided."
        case .malformedOrMissingData:
            return "The data in the receipt-data property was malformed or missing."
        case .receiptCouldNotBeAuthenticated:
            return "The receipt could not be authenticated."
        case .sharedSecretNotMatching:
            return "The shared secret you provided does not match the shared secret on file for your account. Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions."
        case .receiptServerUnavailable:
            return "The receipt server is currently not available."
        case .subscriptioniOS6StyleExpired:
            return "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions."
        case .testReceipt:
            return "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead."
        case .productionEnvironment:
            return "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead."
        case .receiptCouldNotBeAuthorized:
            return "This receipt could not be authorized. Treat this the same as if a purchase was never made."
        case .internalDataAccessError:
            return "Internal data access error (21100-21199)"
        }
    }
}
