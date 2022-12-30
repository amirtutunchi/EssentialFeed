
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
        let loader = FeedLoaderStub(result: .success([feed]))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        expect(sut, toCompleteWith: .success([feed]))
    }
    
    func test_load_returnsErrorOnFailure() {
        let loader = FeedLoaderStub(result: .failure(anyError()))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        expect(sut, toCompleteWith: .failure(anyError()))
    }
}

#if DEBUG
extension FeedLoaderCacheDecoratorTests {
    
}
#endif
