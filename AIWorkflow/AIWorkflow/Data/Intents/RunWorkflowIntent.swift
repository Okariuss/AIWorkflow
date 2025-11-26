//
//  RunWorkflowIntent.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 16.11.2025.
//

import AppIntents
import Foundation

struct RunWorkflowIntent: AppIntent {
    
    static var title: LocalizedStringResource = LocalizedStringResource("intents.run_workflow_title", bundle: .main)
    
    static var description = IntentDescription(
        "intents.run_workflow_description",
        categoryName: "Workflows"
    )
    
    static var openAppWhenRun: Bool = true
    
    // MARK: - Parameters
    
    @Parameter(title: "intents.run_workflow_parameter_workflow")
    var workflow: WorkflowEntity
    
    @Parameter(
        title: "intents.run_workflow_parameter_input_text",
        description: "intents.run_workflow_parameter_input_text_description"
    )
    var inputText: String
    
    // MARK: - Perform
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = DependencyContainer.shared
        
        guard let actualWorkflow = try? await container.workflowRepository.fetch(by: workflow.id) else {
            return .result(dialog: IntentDialog(L10N.Intents.runWorkflowDialogNotFound))
        }
        
        do {
            _ = try await container.workflowExecutionService.executeWorkflow(
                workflow: actualWorkflow,
                inputText: inputText,
                enableLiveActivity: true
            )
            
            return .result(dialog: IntentDialog(L10N.Intents.runWorkflowDialogDone))
            
        } catch {
            return .result(dialog: IntentDialog(L10N.Intents.runWorkflowDialogFailed))
        }
    }
}
