import Foundation
import EssentialFeed

func UniqueItem() -> FeedImage {
    FeedImage(id: UUID(), description: "desc", location: "", url: anyURL())
}

func UniqueItems() -> (models: [FeedImage], local : [LocalFeedImage]) {
    let models = [FeedImage(id: UUID(), description: "desc", location: "", url: anyURL())]
    let locals = models.toLocal()
    return (models, locals)
}


extension Date {
    func minusValidCacheDate() -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: -maxDays, to: self)!
    }
    
    private var maxDays: Int { 7 }
    
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
