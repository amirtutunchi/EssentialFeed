import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public class FeedRefreshViewController: NSObject {
    var delegate: FeedRefreshViewControllerDelegate?
    @IBOutlet private var view: UIRefreshControl?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}

// MARK: - Loading Presenter

extension FeedRefreshViewController: FeedLoadingView {
    func loadingStateChanged(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
