public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(url: URL, completionHandler: @escaping (HTTPClientResult) -> Void)
}
