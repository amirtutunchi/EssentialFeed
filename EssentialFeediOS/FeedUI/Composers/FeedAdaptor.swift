import EssentialFeed
import UIKit

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