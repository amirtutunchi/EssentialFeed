import UIKit
import EssentialFeed

public final class FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let feedRefreshViewController = FeedRefreshViewController(loadFeed: feedPresenter.loadFeed)
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
