public struct FeedViewModel: Equatable {
    public init(feeds: [FeedImage]) {
        self.feeds = feeds
    }
    
    public let feeds: [FeedImage]
}
