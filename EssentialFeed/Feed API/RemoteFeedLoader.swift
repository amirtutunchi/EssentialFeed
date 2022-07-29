import Foundation

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
                do {
                    let feeds = try FeedItemMapper.map(data: data, response: response)
                    completion(.success(feeds))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
