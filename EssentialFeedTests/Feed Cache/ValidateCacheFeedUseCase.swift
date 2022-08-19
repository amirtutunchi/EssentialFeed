import XCTest
import EssentialFeed

class ValidateCacheFeedUseCase: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let ( _, store) = makeSUT()
        XCTAssertEqual(store.messages, [])
    }
}

#if DEBUG
extension ValidateCacheFeedUseCase {
    private func makeSUT(timeStamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timeStamp: timeStamp)
        addTrackForMemoryLeak(object: store, file: file, line: line)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return (sut, store)
    }
}
#endif
