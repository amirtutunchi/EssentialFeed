import XCTest
import EssentialFeed

class ValidateCacheFeedUseCase: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let ( _, store) = makeSUT()
        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_deleteCacheIfLoadsFailed() {
        let (sut, store) = makeSUT()
        sut.validateCache { _ in}
        store.completeRetrieval(with: anyError())
        XCTAssertEqual(store.messages, [.retrieve, .delete])
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
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    private func UniqueItem() -> FeedImage {
        FeedImage(id: UUID(), description: "desc", location: "", url: anyURL())
    }
    private func UniqueItems() -> (models: [FeedImage], local : [LocalFeedImage]) {
        let models = [FeedImage(id: UUID(), description: "desc", location: "", url: anyURL())]
        let locals = models.toLocal()
        return (models, locals)
    }
    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
}
#endif
