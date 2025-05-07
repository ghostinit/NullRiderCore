//
//  Logger.swift
//  BasePackage
//
//  Created by Adam Lyon on 4/22/25.
//
// TODO: Cache and reuse the timestamp formatter for better performance
// TODO: Add option to log into a shared log file instead of daily files
// TODO: Implement log file size limit + rotation strategy
// TODO: Add support for remote logging (optional endpoint config)
// TODO: Create a SwiftUI LogView for real-time in-app viewing
// TODO: Consider enabling JSON log output for integration with tools like Logtail or Datadog

import Foundation
import SwiftData

/// A thread-safe, multi-target logger for SwiftUI apps and CLI tools.
///
/// Logs are:
/// - Printed to console (optional, based on AppSettingsManager.verboseLogging)
/// - Stored to disk in daily files
/// - Cached in memory (up to `maxLogLines` entries)
///
/// Logging can be filtered by log level and optionally enriched with caller context info.
public final class Logger: @unchecked Sendable, ObservableObject {

    /// Singleton instance for global access
    public static let shared = Logger()

    /// Queue to perform disk logging off the main thread
    private let logQueue = DispatchQueue(label: "com.nullrider.logger", qos: .utility)

    /// Path to the current log file (based on date)
    private let fileURL: URL

    /// The minimum log level required for messages to be stored
    public var minimumLogLevel: LogLevel    //Sets the minimum log level
    var verboseLogging : Bool               //Prints to the debug screen
    var useAllLogInformation : Bool         //Includes more source information in the log messages
    

    /// Provides access to user-defined app settings
    //let settings = AppSettingsManager.shared

    /// Live in-memory cache of recent logs (published for views)
    @Published private(set) var inMemoryLog: [String] = []

    /// Limit memory usage by truncating old logs
    private let maxLogLines = 500

    /// Sets up the logger file path and reads default settings
    private init() {
        let today = Date()
        let formattedDate = DateFormatterHelper.formattedFileDate(from: today)
        let filename = "\(formattedDate)_EVENT_LOG.txt"

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = directory.appendingPathComponent(filename)
        
        minimumLogLevel = LogLevel.info
        verboseLogging = true
        useAllLogInformation = false
    }
    
    func configureLogger(with config: LoggerConfiguration) {
        self.verboseLogging = config.verboseLogging
        self.useAllLogInformation = config.useAllLogInformation
        self.minimumLogLevel = LogLevel.from(config.minimumLogLevel)
    }
    
    func getCurrentConfig() -> LoggerConfiguration {
        var currentConfig = LoggerConfiguration(
            verboseLogging: self.verboseLogging,
            useAllLogInformation: self.useAllLogInformation,
            minimumLogLevel: self.minimumLogLevel.rank)
        return currentConfig
    }
    
    /// Logs a message to file and memory (and console if enabled)
    /// - Parameters:
    ///   - message: The main log string
    ///   - level: Log severity (default: `.info`)
    ///   - function: Auto-captured function context
    ///   - file: Auto-captured source filename
    ///   - line: Auto-captured line number
    func log(
        _ message: String,
        level: LogLevel = .info,
        function: String = #function,
        file: String = #fileID,
        line: Int = #line
    ) {
        var callerInfo: String = ""
        if useAllLogInformation {
            callerInfo = "[\(file):\(line) \(function)]"
        } else {
            let fileName = file.components(separatedBy: "/").last ?? file
            callerInfo = "[\(fileName):\(line)]"
        }

        if verboseLogging {
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

    /// Logs a debug message
    public func logDebug(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .debug, function: function, file: file, line: line)
    }

    /// Logs an info message
    public func logInfo(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .info, function: function, file: file, line: line)
    }

    /// Logs a warning message
    public func logWarning(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .warning, function: function, file: file, line: line)
    }

    /// Logs an error message
    public func logError(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .error, function: function, file: file, line: line)
    }

    /// Logs a critical message
    public func logCritical(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        log(message, level: .critical, function: function, file: file, line: line)
    }

    /// Returns the current log file URL
    func getLogFileURL() -> URL {
        return fileURL
    }

    /// Formats the current timestamp for log entries
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }

    /// Clears the in-memory log buffer
    public func clearInMemoryLog() {
        self.inMemoryLog.removeAll()
    }
}

public struct LoggerConfiguration {
    var verboseLogging : Bool       //Prints to the debug screen
    var useAllLogInformation : Bool //Includes more source information in the log messages
    var minimumLogLevel : Int       //Minimum log level
}

/// Describes the severity of a log entry
public enum LogLevel: String, Comparable, CaseIterable, Codable {
    case debug
    case info
    case warning
    case error
    case critical

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rank < rhs.rank
    }

    public var rank: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .warning: return 2
        case .error: return 3
        case .critical: return 4
        }
    }

    /// Converts an integer value into a corresponding log level
    public static func from(_ intValue: Int) -> LogLevel {
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
