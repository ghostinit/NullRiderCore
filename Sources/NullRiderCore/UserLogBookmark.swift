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
final class UserLogBookmark {
    var line: String                   // The raw log entry
    var severity: LogLevel         // Severity at time of bookmark
    var file: String                  // Source file (if known)
    var function: String              // Function context
    var lineNumber: Int               // Source code line (if known)
    var taggedByUser: Bool            // Was this marked by user manually?
    var savedAt: Date                 // Timestamp of when the bookmark was saved
    var note: String?                 // Optional user note

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
    static func addBookmark(
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

