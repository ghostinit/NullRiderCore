//
//  EnvironmentConfig.swift
//  NullRiderCore
//
//  Created by Adam Lyon on 2025-05-05.
//

import Foundation

/// Defines app-wide settings and flags based on the current build environment.
/// Useful for toggling API endpoints, debug features, logging, etc.
public enum EnvironmentConfig {

    /// The current active environment.
    public static var current: AppEnvironment = AppInfo.currentEnvironment

    /// Enable or disable verbose logging based on the environment.
    public static var isDebugLoggingEnabled: Bool {
        switch current {
        case .development: return true
        case .staging, .production: return false
        }
    }

    /// Base URL used for network calls, varies by environment.
    public static var apiBaseURL: String {
        switch current {
        case .development: return "https://api.dev.nullrider.com"
        case .staging: return "https://api.staging.nullrider.com"
        case .production: return "https://api.nullrider.com"
        }
    }

    /// Toggle availability of experimental or in-progress features.
    public static var showBetaFeatures: Bool {
        switch current {
        case .development: return true
        case .staging: return true
        case .production: return false
        }
    }
}

/// Enum defining different environments your app might be built for.
public enum AppEnvironment: String, Codable, CaseIterable {
    case development
    case staging
    case production
}

