import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BufferTests.allTests),
        testCase(SwiftQueuePerformanceTests.allTests),
    ]
}
#endif
