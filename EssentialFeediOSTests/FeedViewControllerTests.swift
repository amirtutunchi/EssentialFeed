import XCTest
import EssentialFeediOS
import EssentialFeed

class FeedViewControllerTests: XCTestCase {
    
    func test_loadFlow_loadDataCorrespondingly() {
        let (sut , loader) = makeSUT()
        XCTAssertEqual(loader.loadCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCount, 1)
    
        sut.userInitiatedReloads()
        XCTAssertEqual(loader.loadCount, 2)
        
        sut.userInitiatedReloads()
        XCTAssertEqual(loader.loadCount, 3)
    }
    
    func test_loadingIndicator_changeCorrectlyBasedOnState() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
   
        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
   
        sut.userInitiatedReloads()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
  
        loader.completeFeedLoading(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
}

#if DEBUG
class LoaderSpy: FeedLoader {
    var completions = [(FeedLoader.Result) -> Void]()
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completions.append(completion)
    }
    
    var loadCount: Int {
        completions.count
    }
    
    func completeFeedLoading(at index: Int) {
        completions[index](.success([]))
    }
}

extension FeedViewControllerTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        addTrackForMemoryLeak(object: loader, file: file, line: line)
        return(sut, loader)
    }
}

private extension FeedViewController {
    func userInitiatedReloads() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        self.refreshControl?.isRefreshing ?? false
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
#endif
