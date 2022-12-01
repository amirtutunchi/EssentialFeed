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

// MARK: - MainQueue Decorator
private final class MainQueueDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async {
                completion()
            }
        }
        completion()
    }
}

extension MainQueueDecorator: FeedLoader where T == FeedLoader {
    func loadFeed(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        decoratee.loadFeed { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

// MARK: - PresenterAdaptor
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

// MARK: FeedViewController extentions
private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.title = title
        feedViewController.delegate = delegate
        return feedViewController
    }
}
