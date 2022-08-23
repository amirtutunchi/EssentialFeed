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

