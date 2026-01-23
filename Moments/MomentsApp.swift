//
//  MomentsApp.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Baby.self,
            Moment.self,
            Group.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // Ensure the Application Support directory exists
            let fileManager = FileManager.default
            if let supportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                if !fileManager.fileExists(atPath: supportDir.path) {
                    try fileManager.createDirectory(at: supportDir, withIntermediateDirectories: true, attributes: nil)
                }
            }
            
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
