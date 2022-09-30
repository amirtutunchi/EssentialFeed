import XCTest
import UIKit

class FeedViewController: UIViewController {
    private var loader: LoaderSpy?
    
    convenience init(loader: LoaderSpy) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
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
class LoaderSpy {
    var loadCount = 0
    
    func load() {
        loadCount += 1
    }
}
#endif
