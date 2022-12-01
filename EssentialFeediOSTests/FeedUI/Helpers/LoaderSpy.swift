import Foundation
import EssentialFeediOS
import EssentialFeed

#if DEBUG
class LoaderSpy: FeedLoader, ImageLoader {
    // MARK: - FeedLoader
    var completions = [(FeedLoader.Result) -> Void]()
    func loadFeed(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        completions.append(completion)
    }
    
    var loadCount: Int {
        completions.count
    }
    
    func completeFeedLoading(with items: [FeedImage] = [], at index: Int) {
        completions[index](.success(items))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: 0)
        completions[index](.failure(error))
    }
    
    // MARK: - ImageLoader
    private struct TaskSpy: ImageLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    private var imageRequests = [(url: URL, completion: (ImageLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    private(set) var cancelImageURLS = [URL]()
    
    func loadImage(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelImageURLS.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
#endif
