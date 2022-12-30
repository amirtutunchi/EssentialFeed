
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

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_succeedOnReturningData() {
        let feed = UniqueFeed()
        let sut = makeSUT(result: .success([feed]))
        expect(sut, toCompleteWith: .success([feed]))
    }
    
    func test_load_returnsErrorOnFailure() {
        let sut = makeSUT(result: .failure(anyError()))
        expect(sut, toCompleteWith: .failure(anyError()))
    }
}

#if DEBUG
extension FeedLoaderCacheDecoratorTests {
    private func makeSUT(result: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        addTrackForMemoryLeak(object: loader)
        addTrackForMemoryLeak(object: sut)
        return sut
    }
}
#endif
