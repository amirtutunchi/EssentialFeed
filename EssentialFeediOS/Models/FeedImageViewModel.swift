import EssentialFeed
import UIKit

final class FeedImageViewModel {
    private var task: ImageLoaderTask?
    private let imageLoader: ImageLoader
    private let model: FeedImage
    
    public init(imageLoader: ImageLoader, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }
    public var onImageLoad: ((UIImage?) -> Void)?
    
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
                self?.onImageLoad?(UIImage(data: data) ?? nil)
            case .failure:
                self?.onImageLoad?(nil)
            }
        }
    }
    
    func stopLoadingImage() {
        task?.cancel()
    }
    
}
