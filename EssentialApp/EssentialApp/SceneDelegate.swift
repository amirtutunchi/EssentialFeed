import UIKit
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let client = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        let imageLoader = RemoteFeedImageDataLoader(client: client)
        let localFeedLoader = LocalFeedLoader(
            store: CodableFeedStore(storeUrl: .documentsDirectory),
            timeStamp: {
                Date()
            }
        )
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposit(
                primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, feedCache: localFeedLoader),
                fallback: localFeedLoader
            ),
            imageLoader: imageLoader
        )
        window?.rootViewController = feedViewController
    }
    
    private func makeRemoteClient() -> HTTPClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {
        case "offline":
            return AlwaysFailingHTTPClient()
            
        default:
            let session = URLSession(configuration: .ephemeral)
            return URLSessionHTTPClient(session: session)
        }
    }
}

private final class AlwaysFailingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
}
