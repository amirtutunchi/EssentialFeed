public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCache(items: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
}
