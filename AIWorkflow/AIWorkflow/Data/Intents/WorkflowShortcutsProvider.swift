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
                // English
                "Run a workflow in \(.applicationName)",
                
                // Turkish
                "\(.applicationName)'da bir iş akışı çalıştır",
            ],
            shortTitle: "intents.run_workflow_title",
            systemImageName: "play.circle"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor = .blue
}
