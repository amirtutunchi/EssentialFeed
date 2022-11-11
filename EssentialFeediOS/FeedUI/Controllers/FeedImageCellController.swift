import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel
    
    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }
    
    public func view() -> UITableViewCell {
        let cell = bound(FeedImageCell())
        viewModel.startLoadingImage()
        return cell
    }

    public func cancelTask() {
        viewModel.stopLoadingImage()
    }
    
    private func bound(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = viewModel.isLocationContainerHidden
        cell.locationLabel.text = viewModel.locationText
        cell.descriptionLabel.text = viewModel.descriptionText
        viewModel.onImageLoad = { image in
            cell.feedImageView.image = image
        }
        return cell
    }
}
