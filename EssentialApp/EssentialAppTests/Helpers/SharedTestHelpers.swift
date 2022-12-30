import EssentialFeed

#if DEBUG
func UniqueFeed() -> FeedImage {
    FeedImage(id: UUID(), description: "a description ", location: nil, url: URL(string: "https://google.com")!)
}

func anyError() -> NSError {
    NSError(domain: "any error", code: 0)
}
#endif
