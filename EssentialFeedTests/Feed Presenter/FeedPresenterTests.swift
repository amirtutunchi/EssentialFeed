import XCTest

struct FeedLoadingViewModel: Equatable {
    let isLoading: Bool
}
protocol FeedLoadingView {
    func loadingStateChanged(viewModel: FeedLoadingViewModel)
}

public final class FeedPresenter {
    let feedLoadingView: FeedLoadingView
    
    init(feedLoadingView: FeedLoadingView) {
        self.feedLoadingView = feedLoadingView
    }
    
    public func didStartLoadingFeed() {
        feedLoadingView.loadingStateChanged(viewModel: FeedLoadingViewModel(isLoading: true))
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
}

#if DEBUG
private extension FeedPresenterTests {
    
    func makeSUT() -> (FeedPresenter, SpyView) {
        let view = SpyView()
        let sut = FeedPresenter(feedLoadingView: view)
        addTrackForMemoryLeak(object: view)
        addTrackForMemoryLeak(object: sut)
        return(sut, view)
    }
    
    enum Messages: Equatable {
        case loadingStateChanged(FeedLoadingViewModel)
    }
    class SpyView: FeedLoadingView {
        
        func loadingStateChanged(viewModel: FeedLoadingViewModel) {
            messages.append(.loadingStateChanged(viewModel))
        }
        
        var messages = [Messages]()
    }
}
#endif
