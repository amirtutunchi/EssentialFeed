import XCTest
import EssentialFeed
class LocalFeedLoader {
    private let store: FeedStore
    private let dateCreator: () -> Date
    init(store: FeedStore, timeStamp: @escaping () -> Date) {
        self.store = store
        self.dateCreator = timeStamp
    }
    func save(item: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                store.insertCache(items: item, timeStamp: dateCreator())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    private var deleteCacheFeedCallCount = 0
    var deleteCacheCount: Int { deleteCacheFeedCallCount }
    private var insertCacheFeedCallCount = 0
    var insertionCount: Int { insertCacheFeedCallCount }
    
    var insertions = [(items: [FeedItem], timeStamp: Date)]()
    private var deletionCompletion = [DeletionCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCacheFeedCallCount += 1
        deletionCompletion.append(completion)
    }
    func completeDeletion(with error: Error, index: Int = 0) {
        deletionCompletion[index](error)
    }
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletion[index](nil)
    }
    func insertCache(items: [FeedItem], timeStamp: Date) {
        insertCacheFeedCallCount += 1
        insertions.append((items, timeStamp))
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
    
    func test_save_increaseInsertionCountOnSuccessfulCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [UniqueItem(), UniqueItem()]
        sut.save(item: items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertionCount, 1)
    }
    
    func test_save_increaseInsertionWithCorrectTimeStampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(timeStamp: { timestamp })
        let items = [UniqueItem(), UniqueItem()]
        sut.save(item: items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertionCount, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timeStamp, timestamp)
    }
}

//MARK: - Helpers
#if DEBUG
extension CacheFeedUseCaseTests {
    private func makeSUT(timeStamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, timeStamp: timeStamp)
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
