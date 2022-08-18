public enum RetrievalCacheResultType {
    case failure(Error)
    case empty
    case found(feeds: [LocalFeedImage], timeStamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalCacheResultType) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping (RetrievalCompletion))
}
