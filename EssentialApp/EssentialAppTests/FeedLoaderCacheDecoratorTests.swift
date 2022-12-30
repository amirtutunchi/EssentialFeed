
import XCTest
import EssentialFeed

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(item: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

public class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let feedCache: FeedCache
    
    public init(decoratee: FeedLoader, feedCache: FeedCache) {
        self.decoratee = decoratee
        self.feedCache = feedCache
    }
    
    public func loadFeed(completion: @escaping (Result<[EssentialFeed.FeedImage], Error>) -> Void) {
        decoratee.loadFeed { [weak self] result in
            self?.feedCache.save(item:(try? result.get()) ?? []) { _ in }
            completion(result)
        }
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
    
    func test_load_cacheDataIfLoaderSucceed() {
        let feed = UniqueFeed()
        let cache = CacheSpy()
        let sut = makeSUT(result: .success([feed]), feedCache: cache)
        sut.loadFeed { _ in }
        XCTAssertEqual(cache.messages, [.save([feed])])
    }
}

#if DEBUG
extension FeedLoaderCacheDecoratorTests {
    private func makeSUT(result: FeedLoader.Result, feedCache: FeedCache = CacheSpy() , file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, feedCache: feedCache)
        addTrackForMemoryLeak(object: loader)
        addTrackForMemoryLeak(object: sut)
        return sut
    }
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(item: [EssentialFeed.FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(item))
        }
    }
}
#endif
