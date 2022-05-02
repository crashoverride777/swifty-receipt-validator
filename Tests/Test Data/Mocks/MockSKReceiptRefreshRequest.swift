import Foundation
import StoreKit

final class MockSKReceiptRefreshRequest: SKReceiptRefreshRequest {
    struct Stub {
        var start: Result<Void, Error> = .success(())
        var hasReceiptAfterRequest = true
    }

    var stub = Stub()
    private let fileManager: MockFileManager
    
    init(fileManager: MockFileManager) {
        self.fileManager = fileManager
        super.init()
    }
    
    override func start() {
        switch stub.start {
        case .success:
            fileManager.stub.fileExists = stub.hasReceiptAfterRequest
            delegate?.requestDidFinish?(.mock())
        case .failure(let error):
            delegate?.request?(.mock(), didFailWithError: error)
            
        }
    }
}
