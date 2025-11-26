//
//  WorkflowShortcutsProvider.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 16.11.2025.
//

import AppIntents

struct WorkflowShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RunWorkflowIntent(),
            phrases: [
                "Run a workflow in \(.applicationName)",
                "Execute workflow in \(.applicationName)",
                "Run \(\.$workflow) in \(.applicationName)",
                "Process text with \(\.$workflow) in \(.applicationName)"
            ],
            shortTitle: "intents.run_workflow_title",
            systemImageName: "play.circle"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor = .blue
}
