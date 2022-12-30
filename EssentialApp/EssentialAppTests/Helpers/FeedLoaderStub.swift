import EssentialFeed

#if DEBUG
class FeedLoaderStub: FeedLoader {
    let result: FeedLoader.Result

    init(result: Result<[FeedImage], Error>) {
        self.result = result
    }
    
    func loadFeed(completion: @escaping (Result<[EssentialFeed.FeedImage], Error>) -> Void) {
        completion(result)
    }
}
#endif
