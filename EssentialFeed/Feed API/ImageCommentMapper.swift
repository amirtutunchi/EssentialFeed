enum ImageCommentMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func mapping(
        data: Data,
        response: HTTPURLResponse
    ) throws -> [RemoteFeedItem] {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentLoader.Error.invalidData
        }
        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}

