import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel
    
    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }
    
    public func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = viewModel.isLocationContainerHidden
        cell.locationLabel.text = viewModel.locationText
        cell.descriptionLabel.text = viewModel.descriptionText
        viewModel.startLoadingImage()
        return cell
    }

    public func cancelTask() {
        viewModel.stopLoadingImage()
    }
}
