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
        case .noSteps: "Workflow has no steps to execute"
        case .emptyInput: "Input text cannot be empty"
        case .stepFailed(let stepIndex, let error):"Step \(stepIndex + 1) failed: \(error)"
        case .cancelled: "Execution was cancelled"
        case .aiServiceUnavailable: "AI service is not available on this device"
        }
    }
}
