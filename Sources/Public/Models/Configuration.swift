import Foundation

public struct SRVConfiguration: Equatable {
    let productionURL: String
    let sandboxURL: String
    let sessionConfiguration: URLSessionConfiguration
    
    /// SRVConfiguration
    ///
    /// - parameter productionURL: The production url of the server to validate the receipt with.
    /// - parameter sandboxURL: The sandbox url of the server to validate the receipt with.
    /// - parameter sessionConfiguration: The URLSessionConfiguration to make URL requests.
    public init(productionURL: String, sandboxURL: String, sessionConfiguration: URLSessionConfiguration) {
        self.productionURL = productionURL
        self.sandboxURL = sandboxURL
        self.sessionConfiguration = sessionConfiguration
    }
    
    /// Standard validation configuration
    /// Validates directy with apple servers which is not recommended
    public static let standard = SRVConfiguration(
        productionURL: "https://buy.itunes.apple.com/verifyReceipt",
        sandboxURL: "https://sandbox.itunes.apple.com/verifyReceipt",
        sessionConfiguration: .default
    )
}
