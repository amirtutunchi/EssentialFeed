import UIKit
import EssentialFeediOS

#if DEBUG
extension FeedViewController {
    func userInitiatedReloads() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        self.refreshControl?.isRefreshing ?? false
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        let cell = feedImageView(index: index) as? FeedImageCell
        return cell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at index: Int) -> FeedImageCell? {
        let cell = simulateFeedImageViewVisible(at: index)!
        
        let delegate = self.tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        
        return cell
    }
    
    func numberOfLoadedFeed() -> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int { 0 }
    
    func feedImageView(index: Int) -> UITableViewCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: feedImagesSection))
    }
}
#endif
