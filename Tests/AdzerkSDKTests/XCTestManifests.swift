import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AdzerkSDKTests.allTests) +
        testCase(LoggerTests.allTests) +
        testCase(UserKeyStoreKeychainTests.allTests)
    ]
}
#endif
