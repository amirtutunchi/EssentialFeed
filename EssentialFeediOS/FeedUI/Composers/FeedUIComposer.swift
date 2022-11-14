import UIKit
import EssentialFeed

public final class FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let feedRefreshViewController = FeedRefreshViewController(presenter: feedPresenter)
        let feedViewController = FeedViewController(feedRefreshViewController: feedRefreshViewController)
        feedPresenter.feedLoadingView = feedRefreshViewController
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
    
    func display(feed: [FeedImage]) {
        feedViewController?.tableModel = feed.map {
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
