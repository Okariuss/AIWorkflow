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
    
    @AppStorage("appThemePreference") private var appThemePreference: String = UserPreferences.ThemePreference.system.rawValue
    private let dependencyContainer = DependencyContainer.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(dependencyContainer.container)
                .preferredColorScheme(colorSchemeForTheme(appThemePreference))
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }
    
    // MARK: - Theme Management
    private func colorSchemeForTheme(_ themeRawValue: String) -> ColorScheme? {
        guard let theme = UserPreferences.ThemePreference(rawValue: themeRawValue) else {
            return nil
        }
        
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
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
