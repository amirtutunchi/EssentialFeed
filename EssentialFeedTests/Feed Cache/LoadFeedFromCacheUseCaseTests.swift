import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let ( _, store) = makeSUT()
        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_requestCacheReterival() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        var capturedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error):
                capturedError = error
            default:
                XCTFail("Expected error got \(result) instead")
            }
        }
        let error = anyError()
        store.completeRetrieval(with: error)
        XCTAssertEqual(capturedError as? NSError, error)
    }
    
    func test_load_receiveCorrectResultOnEmptyCache() {
        let (sut, store) = makeSUT()
        var capturedResult: [FeedImage]?
        sut.load { result in
            switch result {
            case let .success(feeds):
                capturedResult = feeds
            default:
                XCTFail("Expected result got \(result) instead")
            }
        }
        store.completeRetrievalSuccessfullyWithEmptyCache()
        XCTAssertEqual([], capturedResult)
    }
}

//MARK: - Helpers
#if DEBUG
extension LoadFeedFromCacheUseCaseTests {
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
