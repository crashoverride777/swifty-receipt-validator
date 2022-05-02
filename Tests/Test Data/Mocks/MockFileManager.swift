import Foundation

final class MockFileManager: FileManager {
    struct Stub {
        var fileExists = false
    }
    
    var stub = Stub()
    
    override func fileExists(atPath path: String) -> Bool {
        stub.fileExists
    }
}
