import EssentialFeed
import Foundation

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
   
    var feedLoadingView: FeedLoadingView
    var feedView: FeedView
    
    static var feedTitle: String = {
        Bundle(for: FeedPresenter.self).localizedString(forKey: "FEED_VIEW_TITLE", value: nil, table: "Feed")
    }()
    
    init(feedLoadingView: FeedLoadingView, feedView: FeedView) {
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
    
    public func loadedFeedWithError(error: Error) {
        feedLoadingView.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
