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
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_load_whenViewDidLoad() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
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
#endif
