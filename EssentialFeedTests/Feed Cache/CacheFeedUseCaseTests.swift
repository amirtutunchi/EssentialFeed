import XCTest

class LocalFeedLoader {
    var store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    var numberOfDeleteCaches = 0
    init() {
        
    }
}
class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.numberOfDeleteCaches, 0)
    }
}
