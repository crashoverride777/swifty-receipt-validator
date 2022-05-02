import Foundation

public enum SRVAutoRenewStatus: String, Codable, Equatable {
    // Customer has turned off automatic renewal for their subscription
    case off = "0"
    // Subscription will renew at the end of the current subscription period
    case on = "1"
}
