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

