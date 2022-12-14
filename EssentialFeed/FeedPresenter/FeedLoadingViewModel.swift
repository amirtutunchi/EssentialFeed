import Foundation

public struct FeedLoadingViewModel: Equatable {
    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    let isLoading: Bool
    
}
