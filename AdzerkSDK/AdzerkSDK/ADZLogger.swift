//
//  ADZLogger.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/2/17.
//  Copyright © 2017 Adzerk. All rights reserved.
//

import Foundation

class ADZLogger {
    static let LevelNone = 0
    static let LevelError = 1
    static let LevelWarning = 2
    static let LevelDebug = 3
    
    static var logLevel: Int = {
        let defaultLogLevel = LevelWarning
        
        let args = ProcessInfo.processInfo.arguments
        for i in 0..<args.count {
            let arg = args[i]
            if arg.starts(with: "-com.adzerk.sdk.loglevel") {
                if i+1 < args.count {
                    let scanner = Scanner(string: args[i+1])
                    var intValue: Int = 0
                    if scanner.scanInt(&intValue) {
                        return min(LevelDebug, max(0, intValue))
                    }
                    break
                }
            }
        }
        
        return defaultLogLevel
    }()
    
    func debug(_ message: String) {
        log(message, level: ADZLogger.LevelDebug)
    }
    
    func warn(_ message: String) {
        log(message, level: ADZLogger.LevelWarning)
    }
    
    func error(_ message: String) {
        log(message, level: ADZLogger.LevelError)
    }
    
    private func log(_ message: String, level: Int) {
        guard level <= ADZLogger.logLevel else { return }
        print("[AdzerkSDK] \(message)")
    }
}
