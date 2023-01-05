import Foundation
import EssentialFeed

final class MainQueueDecorator<T> {
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

extension MainQueueDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImage(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImage(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
    
    
}
