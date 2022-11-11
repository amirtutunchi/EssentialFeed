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
    
    func test_loadFeedCompletion_cancelDownloadingImageWhenCellIsNotVisible() {
        let image0 = makeImage(url: URL(string: "http://url0.com")!)
        let image1 = makeImage(url: URL(string: "http://url1.com")!)
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelImageURLS, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelImageURLS, [image0.url])
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelImageURLS, [image0.url, image1.url])
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let image0 = makeImage(url: URL(string: "http://url0.com")!)
        let image1 = makeImage(url: URL(string: "http://url1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
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
    private struct TaskSpy: ImageLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    private var imageRequests = [(url: URL, completion: (ImageLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    private(set) var cancelImageURLS = [URL]()
    
    func loadImage(from url: URL, result: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        imageRequests.append((url, result))
        return TaskSpy { [weak self] in self?.cancelImageURLS.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}

extension FeedViewControllerTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
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
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        let cell = feedImageView(index: index) as? FeedImageCell
        return cell
    }
    
    func simulateFeedImageViewNotVisible(at index: Int) {
        let cell = simulateFeedImageViewVisible(at: index)!
        
        let delegate = self.tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
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
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
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
