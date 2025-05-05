//
//  Logger.swift
//  BasePackage
//
//  Created by Adam Lyon on 4/22/25.
//

// Logger.swift
// A thread-safe, hybrid logger for SwiftUI/macOS/iOS apps and CLI tools

// TODO: Cache and reuse the timestamp formatter for better performance
// TODO: Add option to log into a shared log file instead of daily files
// TODO: Implement log file size limit + rotation strategy
// TODO: Add support for remote logging (optional endpoint config)
// TODO: Create a SwiftUI LogView for real-time in-app viewing
// TODO: Consider enabling JSON log output for integration with tools like Logtail or Datadog
//
//  Logger.swift
//  BasePackage
//
//  Created by Adam Lyon on 4/22/25.
//

// Logger.swift
// A thread-safe, hybrid logger for SwiftUI/macOS/iOS apps and CLI tools

import Foundation
import SwiftData

final class Logger: ObservableObject {
    static let shared = Logger()
    private let logQueue = DispatchQueue(label: "com.nullrider.logger", qos: .utility)
    private let fileURL: URL
    
    var minimumLogLevel: LogLevel
    let settings = AppSettingsManager()
    
    @Published private(set) var inMemoryLog: [String] = []

    private let maxLogLines = 500  // Keep memory usage sane

    private init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = "\(AppInfo.name)_\(formatter.string(from: Date())).txt"

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = directory.appendingPathComponent(filename)
        minimumLogLevel = LogLevel.from(settings.minimumLogLevel)
        
    }

    func log(
        _ message: String,
        level: LogLevel = .info,
        function: String = #function,
        file: String = #fileID,
        line: Int = #line
    ) {
        var callerInfo : String = ""
        if settings.fullLoggingString {
            callerInfo = "[\(file):\(line) \(function)]"
        } else {
            let fileName = file.components(separatedBy: "/").last ?? file
            callerInfo = "[\(fileName):\(line)]"
        }
        
        if settings.debugMode {
            let debugEntry = "[\(level.rawValue.uppercased())] \(callerInfo) \(message)"
            print(debugEntry)
        }

        logQueue.async {
            let timestamp = Self.timestamp()
            let entry = "[\(timestamp)] [\(level.rawValue.uppercased())] \(callerInfo) \(message)"
            guard level >= self.minimumLogLevel else { return }

            // Write to file
            if let data = (entry + "\n").data(using: .utf8) {
                if FileManager.default.fileExists(atPath: self.fileURL.path) {
                    if let handle = try? FileHandle(forWritingTo: self.fileURL) {
                        handle.seekToEndOfFile()
                        handle.write(data)
                        try? handle.close()
                    }
                } else {
                    try? data.write(to: self.fileURL)
                }
            }

            // Update in-memory log
            DispatchQueue.main.async {
                self.inMemoryLog.append(entry)
                if self.inMemoryLog.count > self.maxLogLines {
                    self.inMemoryLog.removeFirst()
                }
            }
            
        }
        
    }
    
    func logDebug(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .debug, function: function, file: file, line: line)
    }

    func logInfo(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .info, function: function, file: file, line: line)
    }

    func logWarning(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .warning, function: function, file: file, line: line)
    }

    func logError(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .error, function: function, file: file, line: line)
    }

    func logCritical(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .critical, function: function, file: file, line: line)
    }


    func getLogFileURL() -> URL {
        return fileURL
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    public func clearInMemoryLog() {
        self.inMemoryLog.removeAll()
    }
}

enum LogLevel: String, Comparable, CaseIterable, Codable {
    case debug
    case info
    case warning
    case error
    case critical

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rank < rhs.rank
    }

    private var rank: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .warning: return 2
        case .error: return 3
        case .critical: return 4
        }
    }
    
    static func from(_ intValue: Int) -> LogLevel {
        switch intValue {
        case 0: return .debug
        case 1: return .info
        case 2: return .warning
        case 3: return .error
        case 4: return .critical
        default: return .info
        }
    }
}

