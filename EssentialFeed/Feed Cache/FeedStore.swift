public typealias CachedFeed = (feeds: [LocalFeedImage], timeStamp: Date)

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping (RetrievalCompletion))
}
