import EssentialFeed

protocol FeedLoadingView {
    func loadingStateChanged(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

public final class FeedPresenter {
    public typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
        
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    public func loadFeed() {
        feedLoadingView?.loadingStateChanged(isLoading: true)
        feedLoader.loadFeed {[weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.feedLoadingView?.loadingStateChanged(isLoading:false)
        }
    }
}
