import XCTest

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    func save() {
        store.deleteCache()
    }
}

class FeedStore {
    private var deleteCacheFeedCallCount = 0
    var deleteCacheCount: Int { deleteCacheFeedCallCount }
    
    func deleteCache() {
        deleteCacheFeedCallCount += 1
    }
}
class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCacheCount, 0)
    }
    
    func test_save_deleteCache() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        sut.save()
        XCTAssertEqual(store.deleteCacheCount, 1)
    }
}
