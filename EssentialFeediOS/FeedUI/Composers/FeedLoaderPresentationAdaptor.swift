import EssentialFeed

final class FeedLoaderPresentationAdaptor: FeedViewControllerDelegate {
    let feedLoader: FeedLoader
    var feedPresenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoadingFeed()
        
        feedLoader.loadFeed { [weak self] result in
            switch result {
            case let .success(feed):
                self?.feedPresenter?.didLoadedFeeds(feeds: feed)
                
            case let .failure(error):
                self?.feedPresenter?.loadedFeedWithError(error: error)
            }
        }
    }
}
