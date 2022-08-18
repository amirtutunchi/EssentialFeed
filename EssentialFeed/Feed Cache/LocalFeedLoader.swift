public final class LocalFeedLoader {
    private let store: FeedStore
    private let dateCreator: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    public init(store: FeedStore, timeStamp: @escaping () -> Date) {
        self.store = store
        self.dateCreator = timeStamp
    }
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
    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve {[unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            
            case let .found(feeds, timeStamp) where self.validateDate(timeStamp):
                completion(.success(feeds.toFeedItem()))
        
            case .empty, .found:
                completion(.success([]))
            }
        }
    }
    private var maxDaysOfValidCache: Int { 7 }
    
    private func validateDate(_ timeStamp: Date) -> Bool {
        guard let maxDate = calendar.date(byAdding: .day, value: maxDaysOfValidCache, to: timeStamp) else {
            return false
        }
        return Date() < maxDate
    }
    private func insertCache(items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
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
