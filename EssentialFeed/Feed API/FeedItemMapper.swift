internal enum FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
        var feeds: [FeedItem] {
            items.map{ $0.feedItem }
        }
    }

    private static var OK_200: Int { 200 }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
        
    internal static func mapping(
        data: Data,
        response: HTTPURLResponse
    ) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let item = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(item.feeds)
    }
}
