public typealias CachedFeed = (feeds: [LocalFeedImage], timeStamp: Date)

public protocol FeedStore {
    typealias DeletionError = Error?
    typealias DeletionCompletion = (DeletionError) -> Void
    
    typealias InsertionError = Error?
    typealias InsertionCompletion = (InsertionError) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping (RetrievalCompletion))
}
