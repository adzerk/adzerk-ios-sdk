import XCTest
@testable import AdzerkSDK

final class LoggerTests: XCTestCase {
    func testDefaultLevelInfo() {
        let logger = Logger()
        XCTAssertEqual(.info, logger.level)
    }
    
    func testDefaultsToOSLog() {
        let logger = Logger()
        XCTAssertTrue(logger.destination is OSLogDestination)
    }
    
    func testLoggingToOSLog() {
        // No assertions, verify manually by opening Console and searching for "adzerk"
        let logger = Logger()
        logger.log(.info, message: "Test log")
    }
    
    func testLoggingToDestination() {
        class MockDestination: LogDestination {
            var messages: [String] = []
            func send(_ level: Logger.Level, message: String, file: StaticString, line: UInt) {
                messages.append(message)
            }
        }
        
        let mockDestination = MockDestination()
        let logger = Logger(destination: mockDestination)
        logger.log(.info, message: "Test message")
        
        XCTAssertEqual(["Test message"], mockDestination.messages)
    }

    static var allTests = [
        ("testDefaultLevelInfo", testDefaultLevelInfo),
        ("testDefaultsToOSLog", testDefaultsToOSLog),
        ("testLoggingToDestination", testLoggingToDestination)
    ]
}
