import XCTest
import EssentialFeediOS
import EssentialFeed
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    func test_onLaunch_displayRemoteFeedWhenHasConnectivity() {
        let feed = launch(httpClient: .online(response))
        
        XCTAssertEqual(feed.numberOfLoadedFeed(), 2)
        XCTAssertEqual(feed.simulateFeedImageViewVisible(at: 0)?.renderedImage, makeImageData())
        XCTAssertEqual(feed.simulateFeedImageViewVisible(at: 1)?.renderedImage, makeImageData())
    }
    
    func test_onLaunch_displayCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineFeeds = launch(httpClient: .online(response))
        onlineFeeds.simulateFeedImageViewVisible(at: 0)
        onlineFeeds.simulateFeedImageViewVisible(at: 1)
        
//        let offlineFeeds = launch(httpClient: .offline)
//        XCTAssertEqual(offlineFeeds.numberOfLoadedFeed(), 2)
//        XCTAssertEqual(offlineFeeds.simulateFeedImageViewVisible(at: 0)?.renderedImage, makeImageData())
//        XCTAssertEqual(offlineFeeds.simulateFeedImageViewVisible(at: 1)?.renderedImage, makeImageData())
    }
    
    func test_onLaunch_displayEmptyFeedWhenCustomerHasNoConnectivityAndNoCachedData() {
        let feed = launch(httpClient: .offline)
        XCTAssertEqual(feed.numberOfLoadedFeed(), 0)
    }
}
#if DEBUG
extension FeedAcceptanceTests {
    private func launch(httpClient: HTTPClientStub = .offline) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
            
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}
#endif
