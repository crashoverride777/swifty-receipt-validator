import Foundation

protocol ResponseValidator: Sendable {
    func validatePurchase(in response: SRVReceiptResponse, productId: String) async throws -> SRVReceiptResponse
    func validateSubscriptions(in response: SRVReceiptResponse, now: Date) async throws -> SRVSubscriptionValidationResponse
}

struct DefaultResponseValidator {

    // MARK: - Properties

    private let bundle: Bundle
    private let isLoggingEnabled: Bool

    // MARK: - Initialization

    init(bundle: Bundle, isLoggingEnabled: Bool) {
        self.bundle = bundle
        self.isLoggingEnabled = isLoggingEnabled
    }
}

// MARK: - ResponseValidator

extension DefaultResponseValidator: ResponseValidator {
    func validatePurchase(in response: SRVReceiptResponse, productId: String) async throws -> SRVReceiptResponse {
        self.print("SVRResponseValidator validating purchase...")
        try await basicValidation(for: response)
        guard let receiptInApp = response.receipt?.inApp.first(where: { $0.productId == productId }) else {
            self.print("SVRResponseValidator purchase validation productIdNotMatching error")
            throw SRVError.productIdNotMatching(response.status)
        }
        
        /*
         To check whether a purchase has been canceled by Apple Customer Support, look for the
         Cancellation Date field in the receipt. If the field contains a date, regardless
         of the subscription’s expiration date, the purchase has been canceled. With respect to
         providing content or service, treat a canceled transaction the same as if no purchase
         had ever been made.
         */
        guard receiptInApp.cancellationDate == nil else {
            self.print("SVRResponseValidator purchase validation cancelled")
            throw SRVError.purchaseCancelled(response.status)
        }
        self.print("SVRResponseValidator purchase validation success")
        return response
    }
    
    func validateSubscriptions(in response: SRVReceiptResponse, now: Date) async throws -> SRVSubscriptionValidationResponse {
        self.print("SVRResponseValidator validating subscriptions...")
        try await basicValidation(for: response)
        guard response.status != .subscriptioniOS6StyleExpired else {
            self.print("SVRResponseValidator subscriptions validation iOS6 style expired")
            throw SRVError.subscriptioniOS6StyleExpired(response.status)
        }
        
        let validationResponse = SRVSubscriptionValidationResponse(
            validSubscriptionReceipts: response.validSubscriptionReceipts(now: now),
            receiptResponse: response
        )
                
        self.print("SVRResponseValidator subscriptions validation success")
        return validationResponse
    }
}

// MARK: - Private Methods

private extension DefaultResponseValidator {
    func basicValidation(for response: SRVReceiptResponse) async throws {
        // Check receipt status code is valid
        guard response.status.isValid else {
            throw SRVError.invalidStatusCode(response.status)
        }
       
        // Unwrap receipt
        guard let receipt = response.receipt else {
            throw SRVError.noReceiptFoundInResponse(response.status)
        }
       
        // Check receipt contains correct bundle id
        guard receipt.bundleId == bundle.bundleIdentifier else {
            throw SRVError.bundleIdNotMatching(response.status)
        }
    }
    
    func print(_ items: Any...) {
        guard isLoggingEnabled else { return }
        Swift.print(items[0])
    }
}
