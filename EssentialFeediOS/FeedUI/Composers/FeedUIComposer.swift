import UIKit
import EssentialFeed

public final class FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let feedRefreshViewController = FeedRefreshViewController(viewModel: viewModel)
        let feedViewController = FeedViewController(feedRefreshViewController: feedRefreshViewController)
        viewModel.onFeedLoad = adaptFeedImageToFeedImageCellController(feedViewController: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
    
    private static func adaptFeedImageToFeedImageCellController(feedViewController: FeedViewController, imageLoader: ImageLoader) -> (([FeedImage]) -> Void) {
        { [weak feedViewController] feeds in
            feedViewController?.tableModel = feeds.map {
                FeedImageCellController.init(imageLoader: imageLoader, model: $0)
            }
        }
    }
}
