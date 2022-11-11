import EssentialFeed

final class FeedImageViewModel {
    private var task: ImageLoaderTask?
    private let imageLoader: ImageLoader
    private let model: FeedImage
    
    public init(imageLoader: ImageLoader, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    var isLocationContainerHidden: Bool {
        model.location == nil
    }
    
    var locationText: String? {
        model.location
    }
    
    var descriptionText: String? {
        model.description
    }
    
    func startLoadingImage() {
        task = imageLoader.loadImage(from: model.url)
    }
    
    func stopLoadingImage() {
        task?.cancel()
    }
}
