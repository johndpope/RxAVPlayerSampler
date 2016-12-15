//
//  Logger.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import Foundation.NSString

struct Logger {
    private init() {
        logLevel = .verbose
    }
    enum LogLevel: Int, CustomStringConvertible {
        case trace = 0, verbose, debug, info, warning, error, none
        var description: String {
            switch self {
            case .trace: return "Trace"
            case .verbose: return "Verbose"
            case .debug: return "Debug"
            case .info: return "Info"
            case .warning: return "Warning"
            case .error: return "Error"
            case .none: return "None"
            }
        }
        var emoji: String {
            switch self {
            case .trace, .verbose: return "🗯🗯🗯"
            case .debug: return "🔹🔹🔹"
            case .info: return "ℹ️ℹ️ℹ️"
            case .warning: return "⚠️⚠️⚠️"
            case .error: return "‼️‼️‼️"
            case .none: return ""
            }
        }
    }
    private static var sharedInstance = Logger()
    fileprivate let dateFormatter = "yyyy-MM-dd HH:mm:ss.SSS"
    fileprivate var logLevel: LogLevel = .none // Defaults
    static func trace(_ logMessage: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        sharedInstance.logger(logMessage, logLevel: .trace, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    static func verbose(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        sharedInstance.logger(logMessage, logLevel: .verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    static func info(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        sharedInstance.logger(logMessage, logLevel: .info, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    static func debug(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        sharedInstance.logger(logMessage, logLevel: .debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    static func warning(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        sharedInstance.logger(logMessage, logLevel: .warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    static func error(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        sharedInstance.logger(logMessage, logLevel: .error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
}

// MARK: - Private
private extension Logger {
    func isEnabled(_ logLevel: Logger.LogLevel) -> Bool {
        return logLevel.rawValue >= self.logLevel.rawValue
    }
    func logger(_ logMessage: String, logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        if isEnabled(logLevel) {
            var logLevelStr: String = ""
            var fileInfoStr: String = ""
            var dateTimeStr: String = ""
            var output: String = ""
            logLevelStr = "[\(logLevel.description)] "
            fileInfoStr = "[\((fileName as NSString).lastPathComponent):\(lineNumber)] "
            let now = Date()
            let dateFormatter = DateFormatter()
            _ = Locale.current
            dateFormatter.dateFormat = self.dateFormatter
            dateTimeStr = "\(dateFormatter.string(from: now)) "
            output += "\(logLevel.emoji) \(dateTimeStr)\(logLevelStr)\(logMessage) \(fileInfoStr)"
            print(output)
        }
    }
}
