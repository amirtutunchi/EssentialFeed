import EssentialFeed
import UIKit

public class FeedViewController: UITableViewController {
    private var feedRefreshViewController: FeedRefreshViewController?
    var tableModel: [FeedImageCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    convenience init(feedRefreshViewController: FeedRefreshViewController) {
        self.init()
        self.feedRefreshViewController = feedRefreshViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = feedRefreshViewController?.view
        
        feedRefreshViewController?.refresh()
    }
}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.row].view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].cancelTask()
    }
}
