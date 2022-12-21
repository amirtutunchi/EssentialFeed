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
        let sut = makeSUT(primaryFeed: primaryFeed, fallbackFeed: fallbackFeed)
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
    private func makeSUT(primaryFeed: FeedImage, fallbackFeed: FeedImage, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposit {
        let primaryLoader = StubLoader(result: .success([primaryFeed]))
        let fallbackLoader = StubLoader(result: .success([fallbackFeed]))
        let sut = FeedLoaderWithFallbackComposit(primary: primaryLoader, fallback: fallbackLoader)
        addTrackForMemoryLeak(object: primaryLoader, file: file, line: line)
        addTrackForMemoryLeak(object: fallbackLoader, file: file, line: line)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return sut
    }
    
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
