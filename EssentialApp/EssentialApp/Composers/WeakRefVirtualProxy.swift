import Foundation
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
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
