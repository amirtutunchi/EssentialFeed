public final class LocalFeedLoader {
    private let store: FeedStore
    private let dateCreator: () -> Date
    public typealias FeedResult = Error?
    public init(store: FeedStore, timeStamp: @escaping () -> Date) {
        self.store = store
        self.dateCreator = timeStamp
    }
    public func save(item: [FeedImage], completion: @escaping (FeedResult) -> Void ) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.insertCache(items: item, completion: completion)
            }
        }
    }
    
    private func insertCache(items: [FeedImage], completion: @escaping (FeedResult) -> Void) {
        self.store.insertCache(items: items.toLocal(), timeStamp: self.dateCreator()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
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
