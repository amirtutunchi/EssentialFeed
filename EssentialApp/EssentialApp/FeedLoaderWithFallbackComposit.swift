import EssentialFeed

public class FeedLoaderWithFallbackComposit: FeedLoader {
    public func loadFeed(completion: @escaping (Result<[EssentialFeed.FeedImage], Error>) -> Void) {
        primary.loadFeed { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.loadFeed(completion: completion)
            }
        }
    }
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
}
