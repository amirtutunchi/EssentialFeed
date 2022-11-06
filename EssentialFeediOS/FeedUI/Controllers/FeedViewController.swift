import EssentialFeed
import UIKit

public class FeedViewController: UITableViewController {
    private var feedRefreshViewController: FeedRefreshViewController?
    private var imageLoader: ImageLoader?
    private var tableModel: [FeedImage] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: ImageLoader) {
        self.init()
        self.feedRefreshViewController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = feedRefreshViewController?.view
        feedRefreshViewController?.onRefresh = { [weak self] feeds in
            self?.tableModel = feeds
        }
        feedRefreshViewController?.refresh()
    }
}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]
        let feedImageController = FeedImageCellController(imageLoader: imageLoader!, model: model)
        cellControllers[indexPath] = feedImageController
        return feedImageController.view()
    }
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
