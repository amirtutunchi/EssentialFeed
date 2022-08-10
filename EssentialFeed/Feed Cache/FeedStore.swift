public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
}
