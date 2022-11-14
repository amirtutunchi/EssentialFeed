import UIKit

public class FeedRefreshViewController: NSObject {
    private let presenter: FeedPresenter
    public init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    private(set) lazy var view = createView(view: UIRefreshControl())
    
    @objc func refresh() {
        presenter.loadFeed()
    }
    
    private func createView(view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

// MARK: - Loading Presenter

extension FeedRefreshViewController: FeedLoadingView {
    func loadingStateChanged(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
