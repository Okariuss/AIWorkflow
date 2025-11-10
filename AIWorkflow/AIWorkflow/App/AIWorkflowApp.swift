//
//  AIWorkflowApp.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import SwiftUI
import SwiftData

@main
struct AIWorkflowApp: App {
    
    private let dependencyContainer = DependencyContainer.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(dependencyContainer.container)
        }
    }
}
