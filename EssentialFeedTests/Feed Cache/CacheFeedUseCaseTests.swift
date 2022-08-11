import XCTest
import EssentialFeed

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
        sut.save(item: UniqueItems().models) { _ in }
        let error = anyError()
        store.completeDeletion(with: error)
        XCTAssertEqual(store.messages, [.delete])
    }
    
    func test_save_increaseInsertionWithCorrectTimeStampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(timeStamp: { timestamp })
        let items = UniqueItems()
        sut.save(item: items.models) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.messages, [.delete, .insert(items.local, timestamp)])
    }
    
    func test_save_returnCorrectErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        let error = anyError()
        expect(sut, expectedError: error) {
            store.completeDeletion(with: error)
        }
    }
    
    func test_save_returnCorrectErrorOnInsertionError() {
        let (sut, store) = makeSUT()
        let error = anyError()
        expect(sut, expectedError: error) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: error)
        }
    }
    
    func test_save_succeedOnInsertionSuccessfully() {
        let (sut, store) = makeSUT()
        expect(sut, expectedError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverErrorAfterSUTDeallocationWhenErrorHappens() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timeStamp: Date.init)
        var receivedErrors = [LocalFeedLoader.FeedResult]()
        sut?.save(item: UniqueItems().models) { receivedErrors.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotDeliverErrorAfterSUTDeallocationWhenInsertionErrorHappens() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timeStamp: Date.init)
        var receivedErrors = [LocalFeedLoader.FeedResult]()
        sut?.save(item: UniqueItems().models) { receivedErrors.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
}

//MARK: - Helpers
#if DEBUG
extension CacheFeedUseCaseTests {
    private func expect(_ sut: LocalFeedLoader, expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let items = [UniqueItem(), UniqueItem()]
        var receivedError: Error?
        let exp = expectation(description: "Wait for completion to run...")
        sut.save(item: items) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? NSError, expectedError, file: file, line: line)
    }
    private func makeSUT(timeStamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timeStamp: timeStamp)
        addTrackForMemoryLeak(object: store, file: file, line: line)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return (sut, store)
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
    
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
#endif
