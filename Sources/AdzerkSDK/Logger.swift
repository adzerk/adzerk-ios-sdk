import os.log

public struct Logger {
    public enum Level: Int {
        case debug
        case info
        case warning
        case error
    }
    
    var level: Level = .info
    let destination: LogDestination
    
    public init(destination: LogDestination = OSLogDestination()) {
        self.destination = destination
    }
    
    public func log(_ level: Level, message: String, file: StaticString = #file, line: UInt = #line) {
        destination.send(level, message: message, file: file, line: line)
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
        os_log("%{public}@", log: log, type: level.osLogType, "\(message)" as! CVarArg)
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
