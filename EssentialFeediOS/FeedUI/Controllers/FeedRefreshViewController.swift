import UIKit

public class FeedRefreshViewController: NSObject {
    private let loadFeed: () -> Void
    public init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    
    private(set) lazy var view = createView(view: UIRefreshControl())
    
    @objc func refresh() {
        loadFeed()
    }
    
    private func createView(view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

// MARK: - Loading Presenter

extension FeedRefreshViewController: FeedLoadingView {
    func loadingStateChanged(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
