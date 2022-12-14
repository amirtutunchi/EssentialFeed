import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel<UIImage>
    var cell: FeedImageCell?
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as? FeedImageCell
        bound()
        viewModel.onImageLoad = { [weak self] image in
            self?.cell?.feedImageView.image = image
        }
        viewModel.startLoadingImage()
        return cell!
    }

    public func cancelTask() {
        releaseCellForReuse()
        viewModel.stopLoadingImage()
    }
    
    private func bound() {
        cell?.locationContainer.isHidden = viewModel.isLocationContainerHidden
        cell?.locationLabel.text = viewModel.locationText
        cell?.descriptionLabel.text = viewModel.descriptionText
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
