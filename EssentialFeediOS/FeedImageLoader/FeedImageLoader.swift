import Foundation

public protocol ImageLoaderTask {
    func cancel()
}
public protocol ImageLoader {
    func loadImage(from url: URL) -> ImageLoaderTask
}

