import EssentialFeed

public final class FeedViewModel {
    public typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
        
    public var loadingStateChanged: Observer<Bool>?
    public var onFeedLoad: Observer<[FeedImage]>?
    
    public func loadFeed() {
        loadingStateChanged?(true)
        feedLoader.loadFeed {[weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.loadingStateChanged?(false)
        }
    }
}
