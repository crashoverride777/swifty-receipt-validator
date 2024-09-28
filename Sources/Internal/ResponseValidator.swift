import Foundation

protocol ResponseValidator: AnyObject {
    func validatePurchase(for response: SRVReceiptResponse, productID: String) async throws -> SRVReceiptResponse
    func validateSubscriptions(for response: SRVReceiptResponse, now: Date) async throws -> SRVSubscriptionValidationResponse
}

final class DefaultResponseValidator {

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
    func validatePurchase(for response: SRVReceiptResponse, productID: String) async throws -> SRVReceiptResponse {
        log("SVRResponseValidator validating purchase...")
        do {
            try basicValidation(for: response)
            guard let receiptInApp = response.receipt?.inApp.first(where: { $0.productId == productID }) else {
                log("SVRResponseValidator purchase validation productIdNotMatching error")
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
                log("SVRResponseValidator purchase validation cancelled")
                throw SRVError.purchaseCancelled(response.status)
            }
            log("SVRResponseValidator purchase validation success")
            return response
        } catch {
            log("SVRResponseValidator purchase validation basic error \(error)")
            throw error
        }
    }
    
    func validateSubscriptions(for response: SRVReceiptResponse, now: Date) async throws -> SRVSubscriptionValidationResponse {
        log("SVRResponseValidator validating subscriptions...")
        do {
            try basicValidation(for: response)
            guard response.status != .subscriptioniOS6StyleExpired else {
                log("SVRResponseValidator subscriptions validation iOS6 style expired")
                throw SRVError.subscriptioniOS6StyleExpired(response.status)
            }
            
            let validationResponse = SRVSubscriptionValidationResponse(
                validSubscriptionReceipts: response.validSubscriptionReceipts(now: now),
                receiptResponse: response
            )
            
            log("SVRResponseValidator subscriptions validation success")
            return validationResponse
        } catch {
            log("SVRResponseValidator subscriptions validation basic error \(error)")
            throw error
        }
    }
}

// MARK: - Private Methods

private extension DefaultResponseValidator {
    func basicValidation(for response: SRVReceiptResponse) throws {
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
    
    func log(_ items: Any...) {
        guard isLoggingEnabled else { return }
        Swift.print(items[0])
    }
}
