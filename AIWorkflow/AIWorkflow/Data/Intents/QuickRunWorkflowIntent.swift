//
//  QuickRunWorkflowIntent.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 16.11.2025.
//

import AppIntents

struct QuickRunWorkflowIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Quick Run Workflow"
    
    static var description = IntentDescription(
        "Quickly run a workflow with default settings",
        categoryName: "Workflows"
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - Parameters
    
    @Parameter(title: "Workflow")
    var workflow: WorkflowEntity
    
    @Parameter(title: "Input Text")
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
        case .workflowNotFound:
            return "Workflow not found"
        case .noSteps:
            return "Workflow has no steps"
        case .executionFailed:
            return "Workflow execution failed"
        }
    }
}
