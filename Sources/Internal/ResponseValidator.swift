import Foundation

protocol ResponseValidator: AnyObject {
    func validatePurchase(in response: SRVReceiptResponse,
                          productId: String,
                          completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void)
    func validateSubscriptions(in response: SRVReceiptResponse,
                               now: Date,
                               completion: @escaping (Result<SRVSubscriptionValidationResponse, Error>) -> Void)
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
    func validatePurchase(in response: SRVReceiptResponse,
                          productId: String,
                          completion: @escaping (Result<SRVReceiptResponse, Error>) -> Void) {
        self.print("SVRResponseValidator validating purchase...")
        basicValidation(for: response) { result in
            switch result {
            case .success:
                guard let receiptInApp = response.receipt?.inApp.first(where: { $0.productId == productId }) else {
                    self.print("SVRResponseValidator purchase validation productIdNotMatching error")
                    completion(.failure(SRVError.productIdNotMatching(response.status)))
                    return
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
                    completion(.failure(SRVError.purchaseCancelled(response.status)))
                    return
                }
                self.print("SVRResponseValidator purchase validation success")
                completion(.success(response))
            case .failure(let error):
                self.print("SVRResponseValidator purchase validation basic error \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func validateSubscriptions(in response: SRVReceiptResponse,
                               now: Date,
                               completion: @escaping (Result<SRVSubscriptionValidationResponse, Error>) -> Void) {
        self.print("SVRResponseValidator validating subscriptions...")
        basicValidation(for: response) { result in
            switch result {
            case .success:
                guard response.status != .subscriptioniOS6StyleExpired else {
                    self.print("SVRResponseValidator subscriptions validation iOS6 style expired")
                    completion(.failure(SRVError.subscriptioniOS6StyleExpired(response.status)))
                    return
                }
                
                let validationResponse = SRVSubscriptionValidationResponse(
                    validSubscriptionReceipts: response.validSubscriptionReceipts(now: now),
                    receiptResponse: response
                )
                        
                self.print("SVRResponseValidator subscriptions validation success")
                completion(.success((validationResponse)))
            case .failure(let error):
                self.print("SVRResponseValidator subscriptions validation basic error \(error)")
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private Methods

private extension DefaultResponseValidator {
    func basicValidation(for response: SRVReceiptResponse, completion: (Result<Void, Error>) -> ()) {
        // Check receipt status code is valid
        guard response.status.isValid else {
            completion(.failure(SRVError.invalidStatusCode(response.status)))
            return
        }
       
        // Unwrap receipt
        guard let receipt = response.receipt else {
            completion(.failure(SRVError.noReceiptFoundInResponse(response.status)))
            return
        }
       
        // Check receipt contains correct bundle id
        guard receipt.bundleId == bundle.bundleIdentifier else {
            completion(.failure(SRVError.bundleIdNotMatching(response.status)))
            return
        }
        
        completion(.success(()))
    }
    
    func print(_ items: Any...) {
        guard isLoggingEnabled else { return }
        Swift.print(items[0])
    }
}
