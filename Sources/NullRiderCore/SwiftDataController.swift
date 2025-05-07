//
//  SwiftDataController.swift
//  NullRiderCore
//
//  Created by Adam Lyon on 4/22/25.
//

import Foundation
import SwiftData

/// A singleton class that manages the SwiftData `ModelContainer` for the app.
///
/// This controller provides access to the app's persistent SwiftData layer and is marked as `@MainActor`
/// to ensure thread safety when accessing data from UI components.
@MainActor
public final class SwiftDataController: ObservableObject {
    /// The shared global instance of the controller.
    static let shared = SwiftDataController()

    /// The main SwiftData container used to manage the app's model context.
    public let container: ModelContainer

    /// Initializes the SwiftData container with an explicit schema and configuration.
    ///
    /// The schema defines which models are part of the store. By default, it is backed by disk (not in-memory).
    private init() {
        do {
            // Define which models should be persisted in SwiftData
            let schema = Schema([UserLogBookmark.self])

            // Set up a named configuration for persistence
            let config = ModelConfiguration(
                "Default",
                schema: schema,
                isStoredInMemoryOnly: false
            )

            // Initialize the container with the schema and configuration
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to load SwiftData container: \(error.localizedDescription)")
        }
    }
}
