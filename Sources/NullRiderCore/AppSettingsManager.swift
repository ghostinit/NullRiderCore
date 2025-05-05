import SwiftUI
import Foundation

class AppSettingsManager: ObservableObject {
    @AppStorage("hasSeenOnboarding") var hasSeenOnBoarding: Bool = false
    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled: Bool = true
    
    @AppStorage("fullLoggingString") var fullLoggingString: Bool = false // Include all name space and function information in the logging string
    @AppStorage("debugMode") var debugMode: Bool = true // Toggle various functionality
    @AppStorage("minimumLogLevel") var minimumLogLevel: Int = 0 // Minimum Log Level
    

}

//Log Levels
//    .debug: 0
//    .info: 1
//    .warning: 2
//    .error: 3
//    .critical: 4
