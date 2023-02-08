enum ImageCommentMapper {
   private struct Root: Decodable {
       let items: [RemoteFeedItem]
   }

   static func mapping(
       data: Data,
       response: HTTPURLResponse
   ) throws -> [RemoteFeedItem] {
       guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
           throw RemoteImageCommentLoader.Error.invalidData
       }
       return root.items
   }
}

