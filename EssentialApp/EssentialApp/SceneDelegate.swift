import UIKit
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let fileURL: URL = .documentsDirectory
    
    private lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        return URLSessionHTTPClient(session: session)
    }()
    
    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
        let imageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localFeedLoader = LocalFeedLoader(
            store: CodableFeedStore(storeUrl: fileURL),
            timeStamp: {
                Date()
            }
        )
        
        let feedViewController =  UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposit(
                primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, feedCache: localFeedLoader),
                fallback: localFeedLoader
            ),
            imageLoader: imageLoader
        ))
        window?.rootViewController = feedViewController
        window?.makeKeyAndVisible()
    }
}
