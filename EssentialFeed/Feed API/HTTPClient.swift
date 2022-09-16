public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(url: URL, completionHandler: @escaping (Result) -> Void)
}
