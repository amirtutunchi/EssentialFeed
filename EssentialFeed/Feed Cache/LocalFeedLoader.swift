public final class LocalFeedLoader {
    private let store: FeedStore
    private let dateCreator: () -> Date
    
    public init(store: FeedStore, timeStamp: @escaping () -> Date) {
        self.store = store
        self.dateCreator = timeStamp
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    public func save(item: [FeedImage], completion: @escaping (SaveResult) -> Void ) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.insertCache(items: item, completion: completion)
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

    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            
            case let .found(feeds, timeStamp) where CachePolicy.validateDate(timeStamp, against: self.dateCreator()):
                completion(.success(feeds.toFeedItem()))
            case .found:
                completion(.success([]))
            case .empty:
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
            case let .found( _, timeStamp) where !CachePolicy.validateDate(timeStamp, against: self.dateCreator()):
                self.store.deleteCachedFeed { _ in }
            case .found:
                break
            case .empty:
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
