public final class LocalFeedLoader {
    private let store: FeedStore
    private let dateCreator: () -> Date
    public typealias FeedResult = Error?
    public init(store: FeedStore, timeStamp: @escaping () -> Date) {
        self.store = store
        self.dateCreator = timeStamp
    }
    public func save(item: [FeedItem], completion: @escaping (FeedResult) -> Void ) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.insertCache(items: item, completion: completion)
            }
        }
    }
    
    private func insertCache(items: [FeedItem], completion: @escaping (FeedResult) -> Void) {
        self.store.insertCache(items: items, timeStamp: self.dateCreator()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}
