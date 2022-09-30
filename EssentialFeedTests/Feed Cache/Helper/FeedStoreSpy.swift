import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    typealias DeletionError = Result<Void, Error>
    typealias DeletionCompletion = (DeletionError) -> Void
    
    typealias InsertionError = Result<Void, Error>
    typealias InsertionCompletion = (InsertionError) -> Void
    
    typealias RetrievalCompletion = (FeedStore.RetrievalResult) -> Void
    enum Message: Equatable {
        case delete
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var messages = [Message]()
    private var deletionCompletion = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    private var retrievalCompletion = [RetrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        messages.append(.delete)
    }
    func completeDeletion(with error: Error, index: Int = 0) {
        deletionCompletion[index](.failure(error))
    }
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletion[index](.success(()))
    }
    func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        messages.append(.insert(items, timeStamp))
    }
    func completeInsertion(with error: Error, index: Int = 0) {
        insertionCompletion[index](.failure(error))
    }

    func completeInsertionSuccessfully(index: Int = 0) {
        insertionCompletion[index](.success(()))
    }
    func retrieve(completion: @escaping (RetrievalCompletion)) {
        retrievalCompletion.append(completion)
        messages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, index: Int = 0) {
        retrievalCompletion[index](.failure(error))
    }
    func completeRetrievalSuccessfullyWithEmptyCache(index: Int = 0) {
        retrievalCompletion[index](.success(.none))
    }
    func completeRetrievalSuccessfully(items: [LocalFeedImage], timeStamp: Date, index: Int = 0) {
        retrievalCompletion[index](.success(.some(CachedFeed(feeds: items, timeStamp: timeStamp))))
    }
    
}
