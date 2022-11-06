import UIKit
import EssentialFeed

public final class FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        
        let feedRefreshViewController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(feedRefreshViewController: feedRefreshViewController)
        feedRefreshViewController.onRefresh = { [weak feedViewController] feeds in
            feedViewController?.tableModel = feeds.map {
                FeedImageCellController.init(imageLoader: imageLoader, model: $0)
            }
        }
        return feedViewController
    }
}
