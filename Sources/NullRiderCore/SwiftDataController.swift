//
//  SwiftDataController.swift
//  BasePackage
//
//  Created by Adam Lyon on 4/22/25.
//

//
//  SwiftDataController.swift
//  NullRiderCore
//
//  Created by Adam Lyon on 4/22/25.
//

import Foundation
import SwiftData

@MainActor
public final class SwiftDataController: ObservableObject {
    static let shared = SwiftDataController()

    let container: ModelContainer

    private init() {
        do {
            let schema = Schema([UserLogBookmark.self])
            let config = ModelConfiguration("Default", schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to load SwiftData container: \(error.localizedDescription)")
        }
    }
}
