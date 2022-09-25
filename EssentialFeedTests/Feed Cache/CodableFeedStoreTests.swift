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
        expect(sut: sut, expectedResult: .success(.none))
    }
    
    func test_retrieve_onEmptyCacheTwiceDoesNotHaveAnySideEffects() {
        let sut = makeSUT()
        expect(sut: sut, toRetrieveExpectedResultTwice: .success(.none))
    }
    
    func test_retrieve_returnCacheAfterInsertion() {
        let sut = makeSUT()
        let feeds = UniqueItems().local
        let timeStamp = Date()
        
        insert((feeds, timeStamp), to: sut)
        
        expect(sut: sut, expectedResult: .success(.some(CachedFeed(feeds: feeds, timeStamp: timeStamp))))
    }
    
    func test_retrieve_hasNoSideEffectsOnFoundCache() {
        let sut = makeSUT()
        let feeds = UniqueItems().local
        let timeStamp = Date()
       
        insert((feeds, timeStamp), to: sut)
        
        expect(sut: sut, toRetrieveExpectedResultTwice: .success(.some(CachedFeed(feeds: feeds, timeStamp: timeStamp))))
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
        expect(sut: sut, expectedResult: .success(.none))
    }
    
    func test_delete_deliverEmptyOnFoundCache() {
        let sut = makeSUT()
        let feeds = UniqueItems().local
        let timeStamp = Date()
        insert((feeds, timeStamp), to: sut)
        delete(sut: sut)
        expect(sut: sut, expectedResult: .success(.none))
    }
    
    func test_delete_deliverErrorOnDeletionError() {
        let storeUrl = cachesDirectory()
        let sut = makeSUT(storeUrl: storeUrl)
        let deletionError = delete(sut: sut)
        XCTAssertNotNil(deletionError)
    }
    
    func test_run_serial() {
        let sut = makeSUT()
        var operationArray = [XCTestExpectation]()
        let op1 = expectation(description: "op1")
        sut.insertCache(items: UniqueItems().local, timeStamp: Date()) { _ in
            operationArray.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "op2")
        sut.retrieve { _ in
            operationArray.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "op3")
        sut.deleteCachedFeed { _ in
            operationArray.append(op3)
            op3.fulfill()
        }
        wait(for: [op1, op2, op3], timeout: 5.0)
        XCTAssertEqual([op1, op2, op3], operationArray)
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
    
    private func expect(sut: FeedStore, toRetrieveExpectedResultTwice: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, expectedResult: toRetrieveExpectedResultTwice, file: file, line: line)
        expect(sut: sut, expectedResult: toRetrieveExpectedResultTwice, file: file, line: line)
    }
    
    private func expect(sut: FeedStore, expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval completion")
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.success(.none), .success(.none)), (.failure, .failure):
                break
            case let (.success(.some(retrievedCache)), .success(.some(expectedCache))):
                XCTAssertEqual(retrievedCache.feeds, expectedCache.feeds, file: file, line: line)
                XCTAssertEqual(retrievedCache.timeStamp, expectedCache.timeStamp, file: file, line: line)
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
        sut.insertCache(items: cache.feeds, timeStamp: cache.timeStamp) { insertionCompilation in
            switch insertionCompilation {
            case .failure(let error):
                retrievalError = error
            default:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return retrievalError
    }
    
    @discardableResult
    private func delete(sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for deletation")
        var receivedError: Error?
        sut.deleteCachedFeed { errorCompilation in
            switch errorCompilation {
            case .failure(let error):
                receivedError = error
            default:
                break
            }
        
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        return receivedError
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
#endif
