//
//  FileStorageHelper.swift
//  NullRiderCore
//
//  Created by Adam Lyon on [Date].
//

import Foundation

/// Represents possible errors encountered during file storage operations.
public enum FileStorageError: Error, LocalizedError {
    case failedToWrite
    case failedToRead
    case fileNotFound
    case failedToDelete

    public var errorDescription: String? {
        switch self {
        case .failedToWrite: return "Failed to write data to file."
        case .failedToRead: return "Failed to read data from file."
        case .fileNotFound: return "File not found."
        case .failedToDelete: return "Failed to delete file."
        }
    }
}

/// A thread-safe helper for saving, loading, and deleting Codable objects from disk.
/// Designed for use in both app-level and shared Core environments.
public final class FileStorageHelper: @unchecked Sendable {
    /// Shared singleton instance of the helper.
    public static let shared = FileStorageHelper()

    private init() {}

    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.nullrider.filestorage.queue")

    /// Saves a Codable object to disk in JSON format.
    /// - Parameters:
    ///   - object: The object to save.
    ///   - filename: The name of the file to write to.
    /// - Throws: `FileStorageError` if encoding or writing fails.
    public func save<T: Codable>(_ object: T, to filename: String) throws {
        try queue.sync {
            let url = try getDocumentsDirectory().appendingPathComponent(filename)
            let data = try JSONEncoder().encode(object)
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                throw FileStorageError.failedToWrite
            }
        }
    }

    /// Loads a Codable object from disk.
    /// - Parameters:
    ///   - type: The expected type to decode.
    ///   - filename: The name of the file to read from.
    /// - Returns: The decoded object.
    /// - Throws: `FileStorageError` if file is missing or decoding fails.
    public func load<T: Codable>(_ type: T.Type, from filename: String) throws -> T {
        try queue.sync {
            let url = try getDocumentsDirectory().appendingPathComponent(filename)
            guard fileManager.fileExists(atPath: url.path) else {
                throw FileStorageError.fileNotFound
            }
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw FileStorageError.failedToRead
            }
        }
    }

    /// Deletes a file from disk.
    /// - Parameter filename: The name of the file to delete.
    /// - Throws: `FileStorageError` if deletion fails.
    public func delete(filename: String) throws {
        try queue.sync {
            let url = try getDocumentsDirectory().appendingPathComponent(filename)
            do {
                try fileManager.removeItem(at: url)
            } catch {
                throw FileStorageError.failedToDelete
            }
        }
    }

    /// Checks whether a file exists on disk.
    /// - Parameter filename: The file name to check.
    /// - Returns: `true` if the file exists, `false` otherwise.
    public func fileExists(_ filename: String) -> Bool {
        queue.sync {
            do {
                let url = try getDocumentsDirectory().appendingPathComponent(filename)
                return fileManager.fileExists(atPath: url.path)
            } catch {
                return false
            }
        }
    }

    /// Gets the URL for the app's document directory.
    /// - Returns: A file URL pointing to the user's document directory.
    /// - Throws: `FileStorageError.failedToWrite` if the path cannot be resolved.
    private func getDocumentsDirectory() throws -> URL {
        guard let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileStorageError.failedToWrite
        }
        return path
    }
}
