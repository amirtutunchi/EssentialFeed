import UIKit
import EssentialFeed

public final class FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        
        let feedLoaderPresentationAdaptor = FeedLoaderPresentationAdaptor(feedLoader: feedLoader)
        let feedRefreshViewController = FeedRefreshViewController(loadFeed: feedLoaderPresentationAdaptor.loadFeed)
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.feedRefreshViewController = feedRefreshViewController
        feedLoaderPresentationAdaptor.feedPresenter = FeedPresenter(
            feedLoadingView: WeakRefVirtualProxy<FeedRefreshViewController>(feedRefreshViewController),
            feedView: FeedAdaptor(
                feedViewController: feedViewController,
                imageLoader: imageLoader
            )
        )
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
    var feedPresenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        feedPresenter?.didStartLoadingFeed()
        feedLoader.loadFeed { [weak self] result in
            switch result {
            case let .success(feeds):
                self?.feedPresenter?.didLoadedFeeds(feeds: feeds)
            case let .failure(error):
                self?.feedPresenter?.loadedFeedWithError(error: error)
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
