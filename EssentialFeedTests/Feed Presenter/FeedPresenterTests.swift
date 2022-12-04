import XCTest

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendAnyMessageOnInit() {
        let sut = SpyView()
        
        XCTAssertEqual(sut.messages, [])
    }
}

#if DEBUG
private extension FeedPresenterTests {
    enum Messages: Equatable {
        
    }
    class SpyView {
        var messages = [Messages]()
    }
}
#endif
