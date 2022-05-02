import Foundation
@testable import SwiftyReceiptValidator

final class MockSessionManager {
    struct Stub {
        var start: (_ urlString: String, _ parameters: Data) -> (Result<Data, Error>) = {
            (_, _) in .success(Data([1, 2, 3]))
        }
    }

    var stub = Stub()
}

extension MockSessionManager: URLSessionManagerType {
    
    func start<T: Encodable>(withURL urlString: String,
                  parameters: T,
                  handler: @escaping (Result<Data, Error>) -> Void) {
        do {
            let parametersData = try JSONEncoder().encode(parameters)
            let completion = stub.start(urlString, parametersData)
            handler(completion)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
