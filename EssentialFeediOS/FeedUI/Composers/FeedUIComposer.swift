import UIKit
import EssentialFeed

public final class FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        
        let feedLoaderPresentationAdaptor = FeedLoaderPresentationAdaptor(feedLoader: MainQueueDecorator(decoratee: feedLoader))
        let feedViewController = FeedViewController.makeWith(
            delegate: feedLoaderPresentationAdaptor,
            title: FeedPresenter.feedTitle
        )
        feedLoaderPresentationAdaptor.feedPresenter = FeedPresenter(
            feedLoadingView: WeakRefVirtualProxy(feedViewController),
            feedView: FeedAdaptor(
                feedViewController: feedViewController,
                imageLoader: MainQueueDecorator(decoratee: imageLoader)
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
