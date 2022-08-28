import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feeds: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeeds: [LocalFeedImage] {
            feeds.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        public init(image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        var local: LocalFeedImage {
            LocalFeedImage(id: self.id, description: self.description, location: self.location, url: self.url)
        }
    }
    private let storeUrl: URL
    init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    func retrieve(completion: @escaping (FeedStore.RetrievalCompletion)) {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        do {
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feeds: cache.localFeeds, timeStamp: cache.timeStamp))
        } catch {
            completion(.failure(error))
        }
    }
    func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let codableFeeds = items.map { CodableFeedImage(image: $0) }
            let encoded = try encoder.encode(Cache(feeds: codableFeeds , timeStamp: timeStamp))
            try encoded.write(to: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeUrl.path) else {
            return completion(nil)
        }
        
        try! FileManager.default.removeItem(at: storeUrl)
        completion(nil)
    }
}


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
    
}

#if DEBUG
// MARK: - Test Helpers
private extension CodableFeedStoreTests {
    private func makeSUT(storeUrl: URL? = nil , file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
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
    
    private func expect(sut: CodableFeedStore, toRetrieveExpectedResultTwice: RetrievalCacheResultType, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, expectedResult: toRetrieveExpectedResultTwice, file: file, line: line)
        expect(sut: sut, expectedResult: toRetrieveExpectedResultTwice, file: file, line: line)
    }
    
    private func expect(sut: CodableFeedStore, expectedResult: RetrievalCacheResultType, file: StaticString = #file, line: UInt = #line) {
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
    private func insert(_ cache: (feeds: [LocalFeedImage], timeStamp: Date), to sut: CodableFeedStore) -> Error? {
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
    private func delete(sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for deletation")
        var receivedError: Error?
        sut.deleteCachedFeed { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
}
#endif
