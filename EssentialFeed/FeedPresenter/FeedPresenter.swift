public final class FeedPresenter {
    let feedLoadingView: FeedLoadingView
    let feedView: FeedView

    public init(feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    public func didStartLoadingFeed() {
        feedLoadingView.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didLoadedFeeds(feeds: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feeds: feeds))
        feedLoadingView.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
