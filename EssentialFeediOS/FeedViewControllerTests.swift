import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load { _ in }
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_load_notLoadAtInit() {
        let (_ , loader) = makeSUT()
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_viewDidLoad_loadFeeds() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCount, 1)
    }
}

#if DEBUG
class LoaderSpy: FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        loadCount += 1
    }
    
    var loadCount = 0
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
#endif
