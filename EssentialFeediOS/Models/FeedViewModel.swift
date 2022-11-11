import Foundation
import EssentialFeed

public final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private var isLoading: Bool = false {
        didSet {
            loadingStateChanged?(isLoading)
        }
    }
    
    public var loadingStateChanged: ((Bool) -> Void)?
    public var onFeedLoad: (([FeedImage])  -> Void)?
    
    public func loadFeed() {
        isLoading = true
        feedLoader.loadFeed {[weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
