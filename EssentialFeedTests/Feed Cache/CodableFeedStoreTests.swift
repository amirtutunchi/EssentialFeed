import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupStore()
    }
    
    override func tearDown() {
        super.tearDown()
        removeStoreSideEffects()
    }
    
    func test_retrieve_onEmptyCacheReturnsEmpty() {
        let sut = makeSUT()
        expect(sut: sut, expectedResult: .empty)
    }
    
    func test_retrieve_onEmptyCacheTwiceDoesNotHaveAnySideEffects() {
        let sut = makeSUT()
        expect(sut: sut, toRetrieveExpectedResultTwice: .empty)
    }
    
    func test_retrieve_returnCacheAfterInsertion() {
        let sut = makeSUT()
        let feeds = UniqueItems().local
        let timeStamp = Date()
        
        insert((feeds, timeStamp), to: sut)
        
        expect(sut: sut, expectedResult: .found(feeds: feeds, timeStamp: timeStamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnFoundCache() {
        let sut = makeSUT()
        let feeds = UniqueItems().local
        let timeStamp = Date()
       
        insert((feeds, timeStamp), to: sut)
        
        expect(sut: sut, toRetrieveExpectedResultTwice: .found(feeds: feeds, timeStamp: timeStamp))
    }
    
    func test_retrieve_deliversFailureOnError() {
        let storeUrl = storeTestSpecificUrl()
        let sut = makeSUT(storeUrl: storeUrl)
        
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        
        expect(sut: sut, expectedResult: .failure(anyError()))
    }
    
    func test_retrieve_deliversFailureTwiceOnError() {
        let storeUrl = storeTestSpecificUrl()
        let sut = makeSUT(storeUrl: storeUrl)
        
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieveExpectedResultTwice: .failure(anyError()))
    }
    
    func test_insert_overridePreviousInsertedCache() {
        let sut = makeSUT()
        let firstInsertionError = insert((UniqueItems().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError)
        
        let feeds = UniqueItems().local
        let timeStamp = Date()
        let latestInsertionError = insert((feeds, timeStamp), to: sut)
        XCTAssertNil(latestInsertionError)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeUrl: invalidURL)
        
        let feeds = UniqueItems().local
        let timeStamp = Date()
        let insertionError = insert((feeds, timeStamp), to: sut)
        
        XCTAssertNotNil(insertionError)
    }
    
    func test_delete_deliverEmptyOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = delete(sut: sut)
        XCTAssertNil(deletionError)
        expect(sut: sut, expectedResult: .empty)
    }
    
    func test_delete_deliverEmptyOnFoundCache() {
        let sut = makeSUT()
        let feeds = UniqueItems().local
        let timeStamp = Date()
        insert((feeds, timeStamp), to: sut)
        delete(sut: sut)
        expect(sut: sut, expectedResult: .empty)
    }
    
    func test_delete_deliverErrorOnDeletionError() {
        let storeUrl = cachesDirectory()
        let sut = makeSUT(storeUrl: storeUrl)
        let deletionError = delete(sut: sut)
        XCTAssertNotNil(deletionError)
    }
}

#if DEBUG
// MARK: - Test Helpers
private extension CodableFeedStoreTests {
    private func makeSUT(storeUrl: URL? = nil , file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl: storeUrl ?? storeTestSpecificUrl())
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return sut
    }
    
    private func storeTestSpecificUrl() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func deleteStore() {
        try? FileManager.default.removeItem(at: storeTestSpecificUrl())
    }
    
    private func setupStore() {
        deleteStore()
    }
    
    private func removeStoreSideEffects() {
        deleteStore()
    }
    
    private func expect(sut: FeedStore, toRetrieveExpectedResultTwice: RetrievalCacheResultType, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, expectedResult: toRetrieveExpectedResultTwice, file: file, line: line)
        expect(sut: sut, expectedResult: toRetrieveExpectedResultTwice, file: file, line: line)
    }
    
    private func expect(sut: FeedStore, expectedResult: RetrievalCacheResultType, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval completion")
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(feedResult, timeStampResult), .found(expectedFeed, expectedTimeStamp)):
                XCTAssertEqual(feedResult, expectedFeed, file: file, line: line)
                XCTAssertEqual(timeStampResult, expectedTimeStamp, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    private func insert(_ cache: (feeds: [LocalFeedImage], timeStamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for retrieve to complete")
        var retrievalError: Error?
        sut.insertCache(items: cache.feeds, timeStamp: cache.timeStamp) { insertionError in
            retrievalError = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return retrievalError
    }
    
    @discardableResult
    private func delete(sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for deletation")
        var receivedError: Error?
        sut.deleteCachedFeed { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
#endif
