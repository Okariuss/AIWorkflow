//
//  WorkflowExecutionEngineProtocol.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 13.11.2025.
//

import Foundation

protocol WorkflowExecutionEngineProtocol {
    func execute(
        workflow: Workflow,
        input: String
    ) async throws -> WorkflowExecutionResult
    
    func executeStreaming(
        workflow: Workflow,
        input: String,
        onStepStart: @escaping (WorkflowStep) -> Void,
        onStepProgress: @escaping (WorkflowStep, String) -> Void,
        onStepComplete: @escaping (StepExecutionResult) -> Void
    ) async throws -> WorkflowExecutionResult
    
    func cancel()
}

enum WorkflowExecutionError: LocalizedError {
    case noSteps
    case emptyInput
    case stepFailed(stepIndex: Int, error: String)
    case cancelled
    case aiServiceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .noSteps: L10N.Error.workflowNotFound
        case .emptyInput: L10N.Error.emptyInput
        case .stepFailed(let stepIndex, let error): L10N.Error.stepFailed(stepIndex + 1, error)
        case .cancelled: L10N.Error.executionCancelled
        case .aiServiceUnavailable: L10N.Error.aiUnavailable
        }
    }
}
