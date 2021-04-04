import Foundation
import XCTest

func XCAssertDictionaryEqual(_ expected: [String: Any], _ actual: [String: Any]) {
    XCTAssertEqual(NSDictionary(dictionary: expected), NSDictionary(dictionary: actual))
}
