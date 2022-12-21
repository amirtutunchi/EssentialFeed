import XCTest
import EssentialFeed

public class FeedLoaderWithFallbackComposit: FeedLoader {
    public func loadFeed(completion: @escaping (Result<[EssentialFeed.FeedImage], Error>) -> Void) {
        primary.loadFeed(completion: completion)
    }
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
}

final class FeedLoaderWithFallbackCompositTests: XCTestCase {
    func test_load_deliversPrimaryFeedLoaderResultOnSuccess() {
        let primaryFeed = UniqueFeed()
        let fallbackFeed = UniqueFeed()
        let primaryLoader = StubLoader(result: .success([primaryFeed]))
        let fallbackLoader = StubLoader(result: .success([fallbackFeed]))
        
        let sut = FeedLoaderWithFallbackComposit(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for loader to complete")
        
        sut.loadFeed { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, [primaryFeed])
            default:
                XCTFail("Should not fail while loading feed")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}

#if DEBUG
extension FeedLoaderWithFallbackCompositTests {
    private class StubLoader: FeedLoader {
        let result: FeedLoader.Result

        init(result: Result<[FeedImage], Error>) {
            self.result = result
        }
        
        func loadFeed(completion: @escaping (Result<[EssentialFeed.FeedImage], Error>) -> Void) {
            completion(result)
        }
    }
    
    private func UniqueFeed() -> FeedImage {
        FeedImage(id: UUID(), description: "a description ", location: nil, url: URL(string: "https://google.com")!)
    }
}

#endif
