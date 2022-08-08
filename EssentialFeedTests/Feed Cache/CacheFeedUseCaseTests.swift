import XCTest
import EssentialFeed
class LocalFeedLoader {
    private let store: FeedStore
    private let dateCreator: () -> Date
    init(store: FeedStore, timeStamp: @escaping () -> Date) {
        self.store = store
        self.dateCreator = timeStamp
    }
    func save(item: [FeedItem], completion: @escaping (Error?) -> Void ) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                store.insertCache(items: item, timeStamp: dateCreator(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    enum Message: Equatable {
        case delete
        case insert([FeedItem], Date)
    }
    
    private(set) var messages = [Message]()
    private var deletionCompletion = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        messages.append(.delete)
    }
    func completeDeletion(with error: Error, index: Int = 0) {
        deletionCompletion[index](error)
    }
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletion[index](nil)
    }
    func insertCache(items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        messages.append(.insert(items, timeStamp))
    }
    func completeInsertion(with error: Error, index: Int = 0) {
        insertionCompletion[index](error)
    }
}
class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let ( _, store) = makeSUT()
        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_deleteCache() {
        let (sut, store) = makeSUT()
        let items = [UniqueItem(), UniqueItem()]
        sut.save(item: items) { _ in }
        XCTAssertEqual(store.messages, [.delete])
    }
    
    func test_save_doesNotInsertCacheOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let items = [UniqueItem(), UniqueItem()]
        sut.save(item: items) { _ in }
        let error = anyError()
        store.completeDeletion(with: error)
        XCTAssertEqual(store.messages, [.delete])
    }
    
    func test_save_increaseInsertionWithCorrectTimeStampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(timeStamp: { timestamp })
        let items = [UniqueItem(), UniqueItem()]
        sut.save(item: items) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.messages, [.delete, .insert(items, timestamp)])
    }
    
    func test_save_returnCorrectErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [UniqueItem(), UniqueItem()]
        let error = anyError()
        var receivedError: Error?
        let exp = expectation(description: "Wait for completion to run...")
        sut.save(item: items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: error)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? NSError, error)
        XCTAssertEqual(store.messages, [.delete])
    }
    func test_save_returnCorrectErrorOnInsertionError() {
        let (sut, store) = makeSUT()
        let items = [UniqueItem(), UniqueItem()]
        let error = anyError()
        var receivedError: Error?
        let exp = expectation(description: "Wait for completion to run...")
        sut.save(item: items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: error)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? NSError, error)
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
