
public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func loadFeed(completion: @escaping (FeedLoader.Result) -> Void)
}
