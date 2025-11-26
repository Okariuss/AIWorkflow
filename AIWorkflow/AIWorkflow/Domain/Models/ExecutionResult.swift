//
//  ExecutionResult.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 13.11.2025.
//

import Foundation

struct StepExecutionResult {
    let step: WorkflowStep
    let output: String
    let duration: TimeInterval
    let startedAt: Date
    let completedAt: Date
    let isSuccess: Bool
    let error: String?
}

struct WorkflowExecutionResult {
    let workflow: Workflow
    let inputText: String
    let finalOutput: String
    let stepResults: [StepExecutionResult]
    let totalDuration: TimeInterval
    let startedAt: Date
    let completedAt: Date
    let status: ExecutionStatus
    let error: String?
}

enum ExecutionStatus: String {
    case success
    case failed
    case cancelled
    
    var title: String {
        switch self {
        case .success: L10N.Common.success
        case .failed: L10N.Execution.Status.failed
        case .cancelled: L10N.Execution.Status.cancelled
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.square"
        case .failed: return "exclamationmark.square"
        case .cancelled: return "xmark.square"
        }
    }
}
