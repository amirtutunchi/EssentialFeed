import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result  in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200, let result = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(result.items.map { $0.feedItem }))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [Item]
}

private struct Item: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var feedItem: FeedItem {
        FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}
