import os.log

public struct Logger: Codable {
    public enum Level: Int, Comparable, Codable {
        case debug
        case info
        case warning
        case error
        
        public static func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    public var level: Level = .info
    let destination: LogDestination
    
    public init(destination: LogDestination = OSLogDestination()) {
        self.destination = destination
    }
    
    private enum CodingKeys: String, CodingKey {
        case level
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.level = try container.decode(Level.self, forKey: .level)
        self.destination = OSLogDestination()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(level, forKey: .level)
    }
    
    public func log(_ level: Level, message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
        if level >= self.level {
            destination.send(level, message: message(), file: file, line: line)
        }
    }    
}

public protocol LogDestination {
    func send(_ level: Logger.Level, message: String, file: StaticString, line: UInt)
}

public struct OSLogDestination: LogDestination {
    
    private let log = OSLog(subsystem: "com.adzerk.sdk", category: "general")

    public init() {
    }
    
    public func send(_ level: Logger.Level, message: String, file: StaticString, line: UInt) {
        os_log("%{public}@", log: log, type: level.osLogType, "\(message)")
    }
}

extension Logger.Level {
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .error
        case .error: return .fault
        }
    }   
}
