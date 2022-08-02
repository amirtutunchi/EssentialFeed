import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnExpectedError: Error { }
    public func get(url: URL, completionHandler: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completionHandler(.success(data, response))
            } else {
                completionHandler(.failure(UnExpectedError()))
            }
        }.resume()
    }
}
