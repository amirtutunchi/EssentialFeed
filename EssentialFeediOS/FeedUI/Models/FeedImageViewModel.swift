import EssentialFeed

final class FeedImageViewModel<Image> {
    public typealias ImageTranslator = (Data) -> Image?
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
    private var imageTranslator: ImageTranslator
    public init(
        imageLoader: FeedImageDataLoader,
        model: FeedImage,
        imageTranslator: @escaping ImageTranslator
    ) {
        self.imageLoader = imageLoader
        self.model = model
        self.imageTranslator = imageTranslator
    }
    public var onImageLoad: ((Image?) -> Void)?
    
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
        task = imageLoader.loadImage(from: model.url) {[weak self] result in
            switch result {
            case let .success(data):
                self?.onImageLoad?(self?.imageTranslator(data) ?? nil)
            case .failure:
                self?.onImageLoad?(nil)
            }
        }
    }
    
    func stopLoadingImage() {
        task?.cancel()
    }
}
