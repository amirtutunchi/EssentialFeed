import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderWithFallbackCompositTests: XCTestCase {
    func test_load_deliversPrimaryFeedLoaderResultOnSuccess() {
        let primaryFeed = UniqueFeed()
        let fallbackFeed = UniqueFeed()
        let sut = makeSUT(primaryResult: .success([primaryFeed]), fallbackResult: .success([fallbackFeed]))
        expect(sut, toCompleteWith: .success([primaryFeed]))
    }
    
    func test_load_deliversFallbackFeedLoaderResultOnPrimaryFailure() {
        let fallbackFeed = UniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success([fallbackFeed]))
        expect(sut, toCompleteWith: .success([fallbackFeed]))
    }
    
    func test_load_deliversErrorOnBothFallbackFeedAndPrimaryFailure() {
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .failure(anyError()))
        expect(sut, toCompleteWith: .failure(anyError()))
    }
}

#if DEBUG
extension FeedLoaderWithFallbackCompositTests {
    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadFeed { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposit {
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposit(primary: primaryLoader, fallback: fallbackLoader)
        addTrackForMemoryLeak(object: primaryLoader, file: file, line: line)
        addTrackForMemoryLeak(object: fallbackLoader, file: file, line: line)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return sut
    }
    
    private func UniqueFeed() -> FeedImage {
        FeedImage(id: UUID(), description: "a description ", location: nil, url: URL(string: "https://google.com")!)
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}

#endif
