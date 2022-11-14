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
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    public func didStartLoadingFeed() {
        feedLoadingView?.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didLoadedFeeds(feeds: [FeedImage]) {
        feedView?.display(viewModel: FeedViewModel(feeds: feeds))
        feedLoadingView?.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    public func loadedFeedWithError(error: Error) {
        feedLoadingView?.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
