import Foundation

public final class RemoteImageCommentLoader: FeedLoader {
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
    
    public typealias Result = FeedLoader.Result
    
    public func loadFeed(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteImageCommentLoader.map(data: data, response: response))
            case .failure:
                completion(.failure(RemoteImageCommentLoader.Error.connectivity))
            }
        }
    }
    static func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentMapper.mapping(data: data, response: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}
