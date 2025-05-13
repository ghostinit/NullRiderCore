//
//  KeychainHelper.swift
//  NullRiderCore
//
//  Created by Adam Lyon on 4/22/25.
//

import Foundation
import Security

/// A thread-safe, singleton-based helper for securely saving, reading, updating, and deleting sensitive values in the iOS/macOS keychain.
public final class KeychainHelper: @unchecked Sendable {
    /// The shared global instance.
    public static let shared = KeychainHelper()
    private init() {}

    /// Saves a string value to the keychain.
    /// If a value for the key already exists, it is overwritten.
    /// - Parameters:
    ///   - value: The string to store securely.
    ///   - key: The key used to identify the stored item.
    /// - Returns: `true` if the save succeeded.
    public func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // Remove old item if it exists
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Reads a string value from the keychain.
    /// - Parameter key: The key associated with the stored item.
    /// - Returns: The stored string if it exists and can be decoded.
    public func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    /// Deletes a stored value from the keychain.
    /// - Parameter key: The key identifying the item to delete.
    /// - Returns: `true` if deletion succeeded.
    public func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    /// Updates an existing keychain item with a new value.
    /// - Parameters:
    ///   - value: The new string value.
    ///   - key: The key identifying the item to update.
    /// - Returns: `true` if the update succeeded.
    public func update(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return status == errSecSuccess
    }
}
