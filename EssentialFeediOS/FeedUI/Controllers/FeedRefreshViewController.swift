import UIKit

public class FeedRefreshViewController: NSObject {
    private let viewModel: FeedViewModel
    public init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    private(set) lazy var view = bound(view: UIRefreshControl())
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func bound(view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        viewModel.loadingStateChanged = {[weak view] loadingState in
            if loadingState {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        return view
    }
}

