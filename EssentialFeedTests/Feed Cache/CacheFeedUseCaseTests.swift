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
    
    func deleteCache() {
        deleteCacheFeedCallCount += 1
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
}

//MARK: - Helpers
#if DEBUG
extension CacheFeedUseCaseTests {
    private func makeSUT() -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
    }
    
    private func UniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "desc", location: "", imageURL: URL(string: "http://anyurl.com")!)
    }
}
#endif
