import XCTest
import EssentialFeed

class ValidateCacheFeedUseCase: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let ( _, store) = makeSUT()
        XCTAssertEqual(store.messages, [])
    }
    
    func test_validate_deleteCacheIfLoadsFailed() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrieval(with: anyError())
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_validate_doesNotDeleteCacheOnCacheLessThanSevenDay() {
        let items = UniqueItems()
        let fixedDate = Date().adding(days: -7).adding(seconds: 1)
        
        let (sut, store) = makeSUT { fixedDate }
        sut.validateCache()
        store.completeRetrievalSuccessfully(items: items.local, timeStamp: fixedDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validate_deleteCacheOnSevenDaysOldCache() {
        let items = UniqueItems()
        let date = Date()
        let fixedDate = date.adding(days: -7)
        
        let (sut, store) = makeSUT { date }
        sut.validateCache()
        store.completeRetrievalSuccessfully(items: items.local, timeStamp: fixedDate)
        
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_load_doesDeleteCacheOnCacheMoreThanSevenDay() {
        let items = UniqueItems()
        let date = Date()
        let fixedDate = date.adding(days: -7).adding(seconds: -1)
        
        let (sut, store) = makeSUT { date }
        sut.validateCache()
        store.completeRetrievalSuccessfully(items: items.local, timeStamp: fixedDate)
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_validate_doesNotReturnFeedImagesAfterDeallocation() {
        let fixedDate = Date().adding(days: -7)
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timeStamp: { fixedDate })
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyError())
        XCTAssertEqual(store.messages, [.retrieve])
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
}
#endif
