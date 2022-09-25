public typealias CachedFeed = (feeds: [LocalFeedImage], timeStamp: Date)

public protocol FeedStore {
    typealias DeletionError = Result<Void, Error>
    typealias DeletionCompletion = (DeletionError) -> Void
    
    typealias InsertionError = Result<Void, Error>
    typealias InsertionCompletion = (InsertionError) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping (RetrievalCompletion))
}
