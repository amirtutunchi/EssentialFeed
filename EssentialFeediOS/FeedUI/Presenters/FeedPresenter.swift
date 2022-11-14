import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedLoadingView {
    func loadingStateChanged(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feeds: [FeedImage]
}
protocol FeedView {
    func display(viewModel: FeedViewModel)
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
        feedLoadingView?.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: true))
        feedLoader.loadFeed {[weak self] result in
            if let feeds = try? result.get() {
                self?.feedView?.display(viewModel: FeedViewModel(feeds: feeds))
            }
            self?.feedLoadingView?.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}
