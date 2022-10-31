import EssentialFeed
import UIKit

public protocol ImageLoader {
    func loadImage(from url: URL)
}

public class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: ImageLoader?
    private var tableModel: [FeedImage] = []
    public convenience init(feedLoader: FeedLoader, imageLoader: ImageLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc
    private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.loadFeed {[weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        imageLoader?.loadImage(from: model.url)
        return cell
    }
}
