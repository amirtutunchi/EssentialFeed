import XCTest
import EssentialFeed
class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    func save(item: [FeedItem]) {
        store.deleteCache()
    }
}

class FeedStore {
    private var deleteCacheFeedCallCount = 0
    var deleteCacheCount: Int { deleteCacheFeedCallCount }
    private var insertCacheFeedCallCount = 0
    var insertionCount: Int { insertCacheFeedCallCount }
    
    func deleteCache() {
        deleteCacheFeedCallCount += 1
    }
    func completeDeletion(with error: Error) {
        
    }
}
class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let ( _, store) = makeSUT()
        XCTAssertEqual(store.deleteCacheCount, 0)
    }
    
    func test_save_deleteCache() {
        let (sut, store) = makeSUT()
        let items = [UniqueItem(), UniqueItem()]
        sut.save(item: items)
        XCTAssertEqual(store.deleteCacheCount, 1)
    }
    
    func test_save_doesNotInsertCacheOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let items = [UniqueItem(), UniqueItem()]
        sut.save(item: items)
        let error = anyError()
        store.completeDeletion(with: error)
        XCTAssertEqual(store.insertionCount, 0)
    }
}

//MARK: - Helpers
#if DEBUG
extension CacheFeedUseCaseTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        addTrackForMemoryLeak(object: store, file: file, line: line)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func UniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "desc", location: "", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
#endif
