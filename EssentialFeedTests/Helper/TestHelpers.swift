import Foundation

func anyURL() -> URL {
    URL(string: "http://a-url.com")!
}

func anyError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    Data("any Data".utf8)
}
extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
