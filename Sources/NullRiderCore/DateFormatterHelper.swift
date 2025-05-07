//
//  DateFormatterHelper.swift
//  NullRiderCore
//
//  Created by Adam Lyon on 2025-05-05.
//

import Foundation

/// A utility struct for creating and reusing common `DateFormatter` instances.
/// Avoids performance hits by reusing formatters instead of recreating them.
public struct DateFormatterHelper {

    /// Shared formatter for timestamps like `2025-05-05 15:30:45`
    public static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    /// Shared formatter for filenames like `2025-05-05`
    public static let fileDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    /// Returns a formatted string using the timestamp formatter
    /// - Parameter date: The date to format
    /// - Returns: A formatted string like `2025-05-05 15:30:45`
    public static func formattedTimestamp(from date: Date) -> String {
        return timestampFormatter.string(from: date)
    }

    /// Returns a formatted string using the file date formatter
    /// - Parameter date: The date to format
    /// - Returns: A formatted string like `2025-05-05`
    public static func formattedFileDate(from date: Date) -> String {
        return fileDateFormatter.string(from: date)
    }
}
