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
  
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeFeedImage(description: "a description", location: "a location")
        let image1 = makeFeedImage(description: nil, location: "another location")
        let image2 = makeFeedImage(description: "another description", location: nil)
        let image3 = makeFeedImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.refreshControl?.simulatePullToRefresh()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotHideLoadedCellWhenErrorHappens() {
        let image0 = makeFeedImage(description: "a description", location: "a location")
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.refreshControl?.simulatePullToRefresh()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadFeedCompletion_downloadImageWhenCellIsVisible() {
        let image0 = makeImage(url: URL(string: "http://url0.com")!)
        let image1 = makeImage(url: URL(string: "http://url1.com")!)
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewVisible(at: 1)        
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
}

#if DEBUG
class LoaderSpy: FeedLoader, ImageLoader {
    // MARK: - FeedLoader
    var completions = [(FeedLoader.Result) -> Void]()
    func loadFeed(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        completions.append(completion)
    }
    
    var loadCount: Int {
        completions.count
    }
    
    func completeFeedLoading(with items: [FeedImage] = [], at index: Int) {
        completions[index](.success(items))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: 0)
        completions[index](.failure(error))
    }
    
    // MARK: - ImageLoader
    var loadedImageURLs = [URL]()
    
    func loadImage(from url: URL) {
        loadedImageURLs.append(url)
    }
}

extension FeedViewControllerTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        addTrackForMemoryLeak(object: loader, file: file, line: line)
        return(sut, loader)
    }
    private func makeImage(url: URL) -> FeedImage {
        FeedImage(id: UUID(), description: nil, location: nil, url: url)
    }
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfLoadedFeed() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfLoadedFeed()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(index: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
    }
    private func makeFeedImage(description: String?, location: String?) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: URL(string: "http://any-url.com")!)
    }
}

private extension FeedViewController {
    func userInitiatedReloads() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        self.refreshControl?.isRefreshing ?? false
    }
    
    func simulateFeedImageViewVisible(at index: Int) {
        _ = feedImageView(index: index)
    }
    
    func numberOfLoadedFeed() -> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int { 0 }
    
    func feedImageView(index: Int) -> UITableViewCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: feedImagesSection))
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
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
