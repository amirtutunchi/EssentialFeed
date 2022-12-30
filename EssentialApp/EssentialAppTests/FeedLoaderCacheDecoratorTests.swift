
import XCTest
import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    
    public init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    public func loadFeed(completion: @escaping (Result<[EssentialFeed.FeedImage], Error>) -> Void) {
        decoratee.loadFeed(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase {
    
    func test_load_succeedOnReturningData() {
        let feed = UniqueFeed()
        let loader = StubLoader(result: .success([feed]))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        expect(sut, toCompleteWith: .success([feed]))
    }
    func test_load_returnsErrorOnFailure() {
        let loader = StubLoader(result: .failure(anyError()))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        expect(sut, toCompleteWith: .failure(anyError()))
    }
}
#if DEBUG
extension FeedLoaderCacheDecoratorTests {
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
    
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}

#endif
