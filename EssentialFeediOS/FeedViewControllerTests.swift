import XCTest

class FeedViewController {
    let loader: LoaderSpy
    
    init(loader: LoaderSpy) {
        self.loader = loader
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_load_notLoadAtInit() {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCount, 0)
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
