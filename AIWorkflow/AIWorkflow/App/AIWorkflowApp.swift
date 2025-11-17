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
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }
    
    // MARK: - URL Handling
    private func handleURL(_ url: URL) {
        guard url.scheme == "aiworkflow",
              url.host == "run",
              let workflowIdString = url.pathComponents.last,
              let workflowId = UUID(uuidString: workflowIdString) else {
            return
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenWorkflow"),
            object: nil,
            userInfo: ["workflowId": workflowId]
        )
    }
}
