import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let feedCache: FeedCache
    
    public init(decoratee: FeedLoader, feedCache: FeedCache) {
        self.decoratee = decoratee
        self.feedCache = feedCache
    }
    
    public func loadFeed(completion: @escaping (Result<[EssentialFeed.FeedImage], Error>) -> Void) {
        decoratee.loadFeed { [weak self] result in
            if let feed = try? result.get() {
                self?.feedCache.save(item: feed) { _ in }
            }
            completion(result)
        }
    }
}
