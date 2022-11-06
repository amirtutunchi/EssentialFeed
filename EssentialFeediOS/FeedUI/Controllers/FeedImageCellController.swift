import UIKit
import EssentialFeed

final class FeedImageCellController {
    private var task: ImageLoaderTask?
    
    private let imageLoader: ImageLoader
    private let model: FeedImage
    
    public init(imageLoader: ImageLoader, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    public func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        task = imageLoader.loadImage(from: model.url)
        return cell
    }
    
    deinit {
        task?.cancel()
    }
}
