import SwiftUI
import Foundation

/// A centralized manager for application-level user settings using `@AppStorage`.
///
/// These settings are automatically persisted using UserDefaults and can be updated from anywhere in the app.
@MainActor
public class AppSettingsManager: ObservableObject {
    public static let shared = AppSettingsManager()
    /// Tracks whether the user has completed onboarding.
    @AppStorage("hasSeenOnboarding") public var hasSeenOnBoarding: Bool = false

    /// Toggles dark mode appearance across the app.
    @AppStorage("isDarkModeEnabled") public var isDarkModeEnabled: Bool = true

    /// Determines whether the full logging string should be shown (file/function/etc).
    @AppStorage("fullLoggingString") public var fullLoggingString: Bool = false

    /// Master toggle for whether or not Log Entries should also print to the XCode debug screen.
    @AppStorage("verboseLogging") public var verboseLogging: Bool = true
    
    /// Current App Theme
//    @AppStorage("appTheme") public var appThemeRaw: String = AppTheme.system.rawValue
//
//    public var appTheme: AppTheme {
//        get { AppTheme(rawValue: appThemeRaw) ?? .system }
//        set { appThemeRaw = newValue.rawValue }
//    }

    /// The minimum log level required for messages to appear in logs.
    ///
    /// Log level values:
    /// - 0: debug
    /// - 1: info
    /// - 2: warning
    /// - 3: error
    /// - 4: critical
    @AppStorage("minimumLogLevel") public var minimumLogLevel: Int = 0
}
