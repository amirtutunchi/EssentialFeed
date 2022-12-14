public struct FeedViewModel: Equatable {
    public init(feeds: [FeedImage]) {
        self.feeds = feeds
    }
    
    let feeds: [FeedImage]
}
