import XCTest
import EssentialFeed

struct FeedLoadingViewModel: Equatable {
    let isLoading: Bool
}
protocol FeedLoadingView {
    func loadingStateChanged(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel: Equatable {
    let feeds: [FeedImage]
}
protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedPresenter {
    let feedLoadingView: FeedLoadingView
    let feedView: FeedView

    init(feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    public func didStartLoadingFeed() {
        feedLoadingView.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didLoadedFeeds(feeds: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feeds: feeds))
        feedLoadingView.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}


final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendAnyMessageOnInit() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingFeed_willStartLoadingFeed() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.loadingStateChanged(.init(isLoading: true))])
    }
    
    func test_didLoadedFeed_displayFeedsAndEndFeedLoading() {
        let (sut, view) = makeSUT()
        let anyFeed = UniqueItems()
        sut.didLoadedFeeds(feeds: anyFeed.models)
        
        XCTAssertEqual(view.messages, [.display(.init(feeds: anyFeed.models)), .loadingStateChanged(.init(isLoading: false))])
    }
}

#if DEBUG
private extension FeedPresenterTests {
    
    func makeSUT() -> (FeedPresenter, SpyView) {
        let view = SpyView()
        let sut = FeedPresenter(feedLoadingView: view, feedView: view)
        addTrackForMemoryLeak(object: view)
        addTrackForMemoryLeak(object: sut)
        return(sut, view)
    }
    
    enum Messages: Equatable {
        case loadingStateChanged(FeedLoadingViewModel)
        case display(FeedViewModel)
    }
    
    class SpyView: FeedLoadingView, FeedView {
        func display(viewModel: FeedViewModel) {
            messages.append(.display(viewModel))
        }
        
        
        func loadingStateChanged(viewModel: FeedLoadingViewModel) {
            messages.append(.loadingStateChanged(viewModel))
        }
        
        var messages = [Messages]()
    }
}
#endif
