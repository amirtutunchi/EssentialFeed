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
        let error = anyError()

        expect(sut: sut, expectedResult: .failure(error)) {
            store.completeRetrieval(with: error)
        }
    }
    
    func test_load_receiveCorrectResultOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut: sut, expectedResult: .success([])) {
            store.completeRetrievalSuccessfullyWithEmptyCache()
        }
    }
    
    func test_load_receiveResultOnCacheLessThanSevenDay() {
        let items = UniqueItems()
        let fixedDate = Date().adding(days: -7).adding(seconds: 1)
        
        let (sut, store) = makeSUT { fixedDate }
        expect(sut: sut, expectedResult: .success(items.models)) {
            store.completeRetrievalSuccessfully(items: items.local, timeStamp: fixedDate)
        }
    }
    
    func test_load_returnNoFeedImageOnCacheThatIsSevenDaysOld() {
        let items = UniqueItems()
        let fixedDate = Date().adding(days: -7)
        
        let (sut, store) = makeSUT { fixedDate }
        expect(sut: sut, expectedResult: .success([])) {
            store.completeRetrievalSuccessfully(items: items.local, timeStamp: fixedDate)
        }
    }
    
    func test_load_returnNoFeedImageOnCacheThatIsMoreThanSevenDaysOld() {
        let items = UniqueItems()
        let fixedDate = Date().adding(days: -7).adding(seconds: -1)
        
        let (sut, store) = makeSUT { fixedDate }
        expect(sut: sut, expectedResult: .success([])) {
            store.completeRetrievalSuccessfully(items: items.local, timeStamp: fixedDate)
        }
    }
    
    func test_load_deleteCacheIfLoadsFailed() {
        let (sut, store) = makeSUT()
        sut.load { _ in}
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_load_doesNotDeleteCacheIfLoadsFailedOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.load { _ in}
        store.completeRetrievalSuccessfullyWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
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
    
    private func expect(sut: LocalFeedLoader, expectedResult: LocalFeedLoader.LoadResult, action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to complete")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                        default:
                XCTFail("Expected result got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
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

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
#endif
