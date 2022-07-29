internal enum FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
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
    
    internal static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.items.map { $0.feedItem }
    }
}
