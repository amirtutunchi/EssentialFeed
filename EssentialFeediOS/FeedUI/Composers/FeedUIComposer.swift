import UIKit
import EssentialFeed

public final class FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter()
        let feedLoaderPresentationAdaptor = FeedLoaderPresentationAdaptor(feedLoader: feedLoader, feedPresenter: feedPresenter)
        let feedRefreshViewController = FeedRefreshViewController(loadFeed: feedLoaderPresentationAdaptor.loadFeed)
        let feedViewController = FeedViewController(feedRefreshViewController: feedRefreshViewController)
        feedPresenter.feedLoadingView = WeakRefVirtualProxy<FeedRefreshViewController>(feedRefreshViewController)
        feedPresenter.feedView = FeedAdaptor(feedViewController: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
    
    private static func adaptFeedImageToFeedImageCellController(feedViewController: FeedViewController, imageLoader: ImageLoader) -> (([FeedImage]) -> Void) {
        { [weak feedViewController] feeds in
            feedViewController?.tableModel = feeds.map {
                let viewModel = FeedImageViewModel<UIImage>(
                    imageLoader: imageLoader,
                    model: $0,
                    imageTranslator: { data in
                        UIImage(data: data)
                    }
                )
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}

// MARK: - PresenterAdaptor
final class FeedLoaderPresentationAdaptor {
    let feedLoader: FeedLoader
    let feedPresenter: FeedPresenter
    
    init(feedLoader: FeedLoader, feedPresenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.feedPresenter = feedPresenter
    }
    
    func loadFeed() {
        feedPresenter.didStartLoadingFeed()
        feedLoader.loadFeed { [weak self] result in
            switch result {
            case let .success(feeds):
                self?.feedPresenter.didLoadedFeeds(feeds: feeds)
            case let .failure(error):
                self?.feedPresenter.loadedFeedWithError(error: error)
            }
        }
    }
}

// MARK: - Feed Adaptor

final class FeedAdaptor: FeedView {
    private weak var feedViewController: FeedViewController?
    private let imageLoader: ImageLoader
    
    init(feedViewController: FeedViewController, imageLoader: ImageLoader) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
    
    func display(viewModel: FeedViewModel) {
        feedViewController?.tableModel = viewModel.feeds.map {
            let viewModel = FeedImageViewModel<UIImage>(
                imageLoader: imageLoader,
                model: $0,
                imageTranslator: { data in
                    UIImage(data: data)
                }
            )
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}

// MARK: - Proxies

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func loadingStateChanged(viewModel: FeedLoadingViewModel) {
        object?.loadingStateChanged(viewModel: viewModel)
    }
}
