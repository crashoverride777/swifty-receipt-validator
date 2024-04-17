import Foundation

final class MockBundle: Bundle {
    struct Stub {
        var bundleIdentifier: String = "test.com"
    }
    
    var stub = Stub()
    
    override var bundleIdentifier: String? {
        stub.bundleIdentifier
    }
}
