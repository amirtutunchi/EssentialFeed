public final class LocalFeedLoader {
    private let store: FeedStore
    private let dateCreator: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
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
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            
            case let .found(feeds, timeStamp) where self.validateDate(timeStamp):
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
    private var maxDaysOfValidCache: Int { 7 }
    
    public func validateCache() {
        self.store.retrieve {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .found( _, timeStamp) where !self.validateDate(timeStamp):
                self.store.deleteCachedFeed { _ in }
            case .found:
                break
            case .empty:
                break
            }
        }
    }
    private func validateDate(_ timeStamp: Date) -> Bool {
        guard let maxDate = calendar.date(byAdding: .day, value: maxDaysOfValidCache, to: timeStamp) else {
            return false
        }
        return Date() < maxDate
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
