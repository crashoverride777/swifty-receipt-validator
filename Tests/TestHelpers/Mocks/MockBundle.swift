import Foundation

final class MockBundle: Bundle, @unchecked Sendable {
    struct Stub {
        var bundleIdentifier: String = "test.com"
    }
    
    var stub = Stub()
    
    override var bundleIdentifier: String? {
        stub.bundleIdentifier
    }
}
