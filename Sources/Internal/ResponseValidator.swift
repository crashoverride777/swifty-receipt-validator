import Foundation

protocol ResponseValidatorType: AnyObject {
    func validatePurchase(in response: SRVReceiptResponse,
                          productId: String,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void)
    func validateSubscriptions(in response: SRVReceiptResponse,
                               now: Date,
                               handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void)
}

final class ResponseValidator {

    // MARK: - Properties

    private let bundle: Bundle
    private let isLoggingEnabled: Bool

    // MARK: - Initialization

    init(bundle: Bundle, isLoggingEnabled: Bool) {
        self.bundle = bundle
        self.isLoggingEnabled = isLoggingEnabled
    }
}

// MARK: - ResponseValidatorType

extension ResponseValidator: ResponseValidatorType {
  
    func validatePurchase(in response: SRVReceiptResponse,
                          productId: String,
                          handler: @escaping (Result<SRVReceiptResponse, SRVError>) -> Void) {
        self.print("SVRResponseValidator validating purchase...")
        basicValidation(for: response) { result in
            switch result {
            case .success:
                guard let receiptInApp = response.receipt?.inApp.first(where: { $0.productId == productId }) else {
                    self.print("SVRResponseValidator purchase validation productIdNotMatching error")
                    handler(.failure(.productIdNotMatching(response.status)))
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
                    handler(.failure(.purchaseCancelled(response.status)))
                    return
                }
                self.print("SVRResponseValidator purchase validation success")
                handler(.success(response))
            case .failure(let error):
                self.print("SVRResponseValidator purchase validation basic error \(error)")
                handler(.failure(error))
            }
        }
    }
    
    func validateSubscriptions(in response: SRVReceiptResponse,
                               now: Date,
                               handler: @escaping (Result<SRVSubscriptionValidationResponse, SRVError>) -> Void) {
        self.print("SVRResponseValidator validating subscriptions...")
        basicValidation(for: response) { result in
            switch result {
            case .success:
                guard response.status != .subscriptioniOS6StyleExpired else {
                    self.print("SVRResponseValidator subscriptions validation iOS6 style expired")
                    handler(.failure(.subscriptioniOS6StyleExpired(response.status)))
                    return
                }
                
                let validationResponse = SRVSubscriptionValidationResponse(
                    validSubscriptionReceipts: response.validSubscriptionReceipts(now: now),
                    receiptResponse: response
                )
                        
                self.print("SVRResponseValidator subscriptions validation success")
                handler(.success((validationResponse)))
            case .failure(let error):
                self.print("SVRResponseValidator subscriptions validation basic error \(error)")
                handler(.failure(error))
            }
        }
    }
}

// MARK: - Private Methods

private extension ResponseValidator {
    
    func basicValidation(for response: SRVReceiptResponse, handler: (Result<Void, SRVError>) -> ()) {
        // Check receipt status code is valid
        guard response.status.isValid else {
            handler(.failure(.invalidStatusCode(response.status)))
            return
        }
       
        // Unwrap receipt
        guard let receipt = response.receipt else {
            handler(.failure(.noReceiptFoundInResponse(response.status)))
            return
        }
       
        // Check receipt contains correct bundle id
        guard receipt.bundleId == bundle.bundleIdentifier else {
            handler(.failure(.bundleIdNotMatching(response.status)))
            return
        }
        
        handler(.success(()))
    }
    
    func print(_ items: Any...) {
        guard isLoggingEnabled else { return }
        Swift.print(items[0])
    }
}
