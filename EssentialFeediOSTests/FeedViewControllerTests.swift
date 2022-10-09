import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc
    private func load() {
        loader?.load {[weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

class FeedViewControllerTests: XCTestCase {
    
    func test_load_notLoadAtInit() {
        let (_ , loader) = makeSUT()
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_load_whenViewDidLoad() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    func test_userInitiatedReloads_loadFeeds() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.userInitiatedReloads()
        XCTAssertEqual(loader.loadCount, 2)
        
        sut.userInitiatedReloads()
        XCTAssertEqual(loader.loadCount, 3)
    }
    
    func test_viewDidLoad_showLoadingIndicator() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }
    
    func test_viewDidLoad_hideLoadingIndicatorAfterLoaderCompleted() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_userInitiatedReloads_showLoading() {
        let (sut, _) = makeSUT()
        sut.userInitiatedReloads()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }
    
    func test_userInitiatedReloads_endLoadingAfterLoaderCompleted() {
        let (sut, loader) = makeSUT()
        sut.userInitiatedReloads()
        loader.completeFeedLoading()
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
    
    func completeFeedLoading(at index: Int = 0) {
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
