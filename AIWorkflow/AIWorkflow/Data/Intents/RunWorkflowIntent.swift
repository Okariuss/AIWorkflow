//
//  RunWorkflowIntent.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 16.11.2025.
//

import AppIntents
import Foundation

struct RunWorkflowIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Run Workflow"
    
    static var description = IntentDescription(
        "Runs an AI workflow with the provided input text",
        categoryName: "Workflows"
    )
    
    static var openAppWhenRun: Bool = true
    
    // MARK: - Parameters
    
    @Parameter(title: "Workflow")
    var workflow: WorkflowEntity
    
    @Parameter(
        title: "Input Text",
        description: "The text to process through the workflow"
    )
    var inputText: String
    
    // MARK: - Perform
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = DependencyContainer.shared
        
        guard let actualWorkflow = try? await container.workflowRepository.fetch(by: workflow.id) else {
            return .result(dialog: "I couldn't find that workflow.")
        }
        
        do {
            _ = try await container.workflowExecutionService.executeWorkflow(
                workflow: actualWorkflow,
                inputText: inputText,
                enableLiveActivity: true
            )
            
            return .result(dialog: "Done! Check the app for results.")
            
        } catch {
            return .result(dialog: "Workflow failed. Check the app.")
        }
    }
}
