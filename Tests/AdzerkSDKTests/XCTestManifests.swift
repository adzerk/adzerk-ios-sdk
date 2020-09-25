import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(adzerk_iosTests.allTests),
    ]
}
#endif
