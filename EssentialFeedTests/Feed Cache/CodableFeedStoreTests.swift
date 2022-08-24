import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping (FeedStore.RetrievalCompletion)) {
        completion(.empty)
    }
}


class CodableFeedStoreTests: XCTestCase {
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
}
