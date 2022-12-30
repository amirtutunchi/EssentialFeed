public final class LocalFeedLoader: FeedCache {
    private let store: FeedStore
    private let dateCreator: () -> Date
    
    public init(store: FeedStore, timeStamp: @escaping () -> Date) {
        self.store = store
        self.dateCreator = timeStamp
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>
    public func save(item: [FeedImage], completion: @escaping (SaveResult) -> Void ) {
        store.deleteCachedFeed { [weak self] errorCompilation in
            guard let self = self else { return }
            
            switch errorCompilation {
            case .success:
                self.insertCache(items: item, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    private func insertCache(items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insertCache(items: items.toLocal(), timeStamp: self.dateCreator()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func loadFeed(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            
            case let .success(.some(cache)) where CachePolicy.validateDate(cache.timeStamp, against: self.dateCreator()):
                completion(.success(cache.feeds.toFeedItem()))
            case .success:
                completion(.success([]))
            }
        }
    }
}
extension LocalFeedLoader {
    public func validateCache() {
        self.store.retrieve {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .success(.some(cache)) where !CachePolicy.validateDate(cache.timeStamp, against: self.dateCreator()):
                self.store.deleteCachedFeed { _ in }
            case .success:
                break
            }
        }
    }
}

extension Array where Element == FeedImage {
    public func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

extension Array where Element == LocalFeedImage {
    func toFeedItem() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
