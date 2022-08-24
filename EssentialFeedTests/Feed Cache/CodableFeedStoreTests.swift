import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feeds: [LocalFeedImage]
        let timeStamp: Date
    }
    private let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feedCache.store")
    func retrieve(completion: @escaping (FeedStore.RetrievalCompletion)) {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feeds: cache.feeds, timeStamp: cache.timeStamp))
        
    }
    func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feeds: items, timeStamp: timeStamp))
        try! encoded.write(to: storeUrl)
        completion(nil)
    }
}


class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feedCache.store")
        try? FileManager.default.removeItem(at: storeUrl)
    }
    func test_retrieve_onEmptyCacheReturnsEmpty() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for retrieve to complete")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("expect empty got\(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    func test_retrieve_onEmptyCacheTwiceDoesNotHaveAnySideEffects() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for retrieve to complete")
        sut.retrieve { first in
            sut.retrieve { second in
                switch (first, second) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("expect empty got\(first) and \(second) results instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    func test_retrieve_returnCacheAfterInsertion() {
        let sut = CodableFeedStore()
        let feeds = UniqueItems().local
        let timeStamp = Date()
        let exp = expectation(description: "Wait for retrieve to complete")
        sut.insertCache(items: feeds, timeStamp: timeStamp) { insertionError in
            if let insertionError = insertionError {
                XCTFail("should not failed but failed with \(insertionError)")
            }
            
            sut.retrieve { result in
                switch result {
                case let .found(expectedFeed, expectedTimeStamp):
                    XCTAssertEqual(expectedFeed, feeds)
                    XCTAssertEqual(expectedTimeStamp, timeStamp)
                default:
                    XCTFail("expect \(feeds) and \(timeStamp) got  \(result) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
}
