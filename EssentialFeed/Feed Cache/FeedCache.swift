public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(item: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
