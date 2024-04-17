import Foundation
@testable import SwiftyReceiptValidator

final class StubURLSessionManager {
    struct Stub {
        var start: (_ urlString: String, _ parameters: Data) -> (Result<Data, Error>) = {
            (_, _) in .success(Data([1, 2, 3]))
        }
    }

    var stub = Stub()
}

extension StubURLSessionManager: URLSessionManager {
    func start<T: Encodable>(withURL urlString: String, parameters: T, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let parametersData = try JSONEncoder().encode(parameters)
            let result = stub.start(urlString, parametersData)
            completion(result)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
