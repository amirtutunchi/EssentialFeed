public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feeds: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeeds: [LocalFeedImage] {
            feeds.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        public init(image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        var local: LocalFeedImage {
            LocalFeedImage(id: self.id, description: self.description, location: self.location, url: self.url)
        }
    }
    private let storeUrl: URL
    private var queue = DispatchQueue(label: "back", attributes: .concurrent)
    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    public func retrieve(completion: @escaping (RetrievalCompletion)) {
        let storeUrl = self.storeUrl
        queue.async {
            let decoder = JSONDecoder()
            guard let data = try? Data(contentsOf: storeUrl) else {
                return completion(.success(.empty))
            }
            do {
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(.found(feeds: cache.localFeeds, timeStamp: cache.timeStamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insertCache(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        let storeUrl = self.storeUrl
        queue.async(flags: .barrier){
            do {
                let encoder = JSONEncoder()
                let codableFeeds = items.map { CodableFeedImage(image: $0) }
                let encoded = try encoder.encode(Cache(feeds: codableFeeds , timeStamp: timeStamp))
                try encoded.write(to: storeUrl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeUrl = self.storeUrl
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeUrl.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeUrl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

