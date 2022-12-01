import Foundation

public protocol ImageLoaderTask {
    func cancel()
}
public protocol ImageLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImage(from url: URL, completion: @escaping (Result) -> Void) -> ImageLoaderTask
}

