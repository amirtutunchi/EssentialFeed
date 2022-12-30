import XCTest

extension XCTestCase {
    func addTrackForMemoryLeak(
        object: AnyObject,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "object should be nil if not memory leak detected", file: file, line: line)
        }
    }
}
