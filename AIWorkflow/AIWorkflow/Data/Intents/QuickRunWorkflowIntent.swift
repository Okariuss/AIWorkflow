//
//  QuickRunWorkflowIntent.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 16.11.2025.
//

import AppIntents

struct QuickRunWorkflowIntent: AppIntent {
    
    static let title: LocalizedStringResource = "intents.quick_run_title"
    
    static var description = IntentDescription(
        "intents.quick_run_description",
        categoryName: "Workflows"
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - Parameters
    
    @Parameter(title: "intents.quick_run_parameter_workflow")
    var workflow: WorkflowEntity
    
    @Parameter(title: "intents.quick_run_parameter_input_text")
    var inputText: String
    
    // MARK: - Perform
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let container = DependencyContainer.shared
        
        guard let actualWorkflow = try? await container.workflowRepository.fetch(by: workflow.id) else {
            throw IntentError.workflowNotFound
        }
        
        do {
            _ = try await container.workflowExecutionService.executeWorkflow(
                workflow: actualWorkflow,
                inputText: inputText,
                enableLiveActivity: true
            )
            
            return .result()
            
        } catch {
            throw IntentError.executionFailed
        }
    }
}

// MARK: - Intent Errors
enum IntentError: Error, LocalizedError {
    case workflowNotFound
    case noSteps
    case executionFailed
    
    var errorDescription: String? {
        switch self {
        case .workflowNotFound: L10N.Error.workflowNotFound
        case .noSteps: L10N.Error.noSteps
        case .executionFailed: L10N.Error.executionFailed
        }
    }
}

