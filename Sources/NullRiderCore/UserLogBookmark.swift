//
//  UserLogBookmark.swift
//  NullRiderCore
//
//  Created by Adam Lyon on 4/22/25.
//

import Foundation
import SwiftData

// TODO: Define SavedSetting model (key/value pair)
// TODO: Define AppEvent model (user actions, lifecycle events)
// TODO: Define ErrorReport model (structured crash or error data)
// TODO: Define SessionMetric model (app usage statistics)

//enum LogSeverity: String, Codable, CaseIterable {
//    case debug
//    case info
//    case warning
//    case error
//    case critical
//}

@Model
public final class UserLogBookmark {
    public var line: String                   // The raw log entry
    public var severity: LogLevel         // Severity at time of bookmark
    public var file: String                  // Source file (if known)
    public var function: String              // Function context
    public var lineNumber: Int               // Source code line (if known)
    public var taggedByUser: Bool            // Was this marked by user manually?
    public var savedAt: Date                 // Timestamp of when the bookmark was saved
    public var note: String?                 // Optional user note

    init(
        line: String,
        severity: LogLevel,
        file: String,
        function: String,
        lineNumber: Int,
        taggedByUser: Bool = true,
        savedAt: Date = .now,
        note: String? = nil
    ) {
        self.line = line
        self.severity = severity
        self.file = file
        self.function = function
        self.lineNumber = lineNumber
        self.taggedByUser = taggedByUser
        self.savedAt = savedAt
        self.note = note
    }
}

extension UserLogBookmark {
    public static func addBookmark(
        line: String,
        severity: LogLevel,
        note: String? = nil,
        context: ModelContext,
        file: String = #fileID,
        function: String = #function,
        lineNumber: Int = #line
    ) {
        let bookmark = UserLogBookmark(
            line: line,
            severity: severity,
            file: file,
            function: function,
            lineNumber: lineNumber,
            note: note
        )
        context.insert(bookmark)
    }
}

