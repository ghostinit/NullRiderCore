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

/// A data model representing a bookmarked log entry.
///
/// This model allows users or the system to persist interesting or important log lines
/// for later review, complete with file, function, line number, severity, and optional notes.
@Model
public final class UserLogBookmark {
    /// The raw log line content.
    public var line: String

    /// Severity of the log at the time of bookmarking.
    public var severity: LogLevel

    /// The filename (e.g. HomeView.swift) where the log originated.
    public var file: String

    /// The function name context of the log (e.g. `loadUser()`).
    public var function: String

    /// The line number in the source file.
    public var lineNumber: Int

    /// Indicates whether the user manually tagged the log or it was programmatically bookmarked.
    public var taggedByUser: Bool

    /// Timestamp when the bookmark was saved.
    public var savedAt: Date

    /// Optional note or comment attached to the bookmark.
    public var note: String?

    /// Initializes a new bookmark.
    public init(
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
    /// Adds a new bookmark into the SwiftData model context.
    ///
    /// - Parameters:
    ///   - line: The log message content.
    ///   - severity: The severity level of the log.
    ///   - note: Optional user note or comment.
    ///   - context: The SwiftData context to insert the model into.
    ///   - file: The source file (automatically captured).
    ///   - function: The calling function name (automatically captured).
    ///   - lineNumber: The source code line number (automatically captured).
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
