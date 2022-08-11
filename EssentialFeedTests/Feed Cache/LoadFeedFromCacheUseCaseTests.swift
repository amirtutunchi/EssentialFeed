import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let ( _, store) = makeSUT()
        XCTAssertEqual(store.messages, [])
    }
}

//MARK: - Helpers
#if DEBUG
extension LoadFeedFromCacheUseCaseTests {
    private func makeSUT(timeStamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timeStamp: timeStamp)
        addTrackForMemoryLeak(object: store, file: file, line: line)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return (sut, store)
    }
    
    
    private class FeedStoreSpy: FeedStore {
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void
        enum Message: Equatable {
            case delete
            case insert([LocalFeedImage], Date)
        }
        
        private(set) var messages = [Message]()
        private var deletionCompletion = [DeletionCompletion]()
        private var insertionCompletion = [InsertionCompletion]()
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletion.append(completion)
            messages.append(.delete)
        }
        func completeDeletion(with error: Error, index: Int = 0) {
            deletionCompletion[index](error)
        }
        func completeDeletionSuccessfully(index: Int = 0) {
            deletionCompletion[index](nil)
        }
        func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletion.append(completion)
            messages.append(.insert(items, timeStamp))
        }
        func completeInsertion(with error: Error, index: Int = 0) {
            insertionCompletion[index](error)
        }

        func completeInsertionSuccessfully(index: Int = 0) {
            insertionCompletion[index](nil)
        }
    }
}
#endif
