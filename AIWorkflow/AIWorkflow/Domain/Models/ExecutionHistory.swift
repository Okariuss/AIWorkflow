//
//  ExecutionHistory.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation
import SwiftData

@Model
final class ExecutionHistory {
    var id: UUID
    var workflowId: UUID
    var workflowName: String
    var executedAt: Date
    var duration: Double
    var status: String
    var inputText: String
    var outputText: String
    var stepResultsJSON: String
    
    init(
        id: UUID = UUID(),
        workflowId: UUID,
        workflowName: String,
        executedAt: Date = Date(),
        duration: Double = 0,
        status: String,
        inputText: String,
        outputText: String,
        stepResultsJSON: String = "[]"
    ) {
        self.id = id
        self.workflowId = workflowId
        self.workflowName = workflowName
        self.executedAt = executedAt
        self.duration = duration
        self.status = status
        self.inputText = inputText
        self.outputText = outputText
        self.stepResultsJSON = stepResultsJSON
    }
}

// MARK: - Execution Status
extension ExecutionHistory {
    
    enum Status: String {
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
            case .success: "checkmark.circle.fill"
            case .failed: "xmark.circle.fill"
            case .cancelled: "stop.circle.fill"
            }
        }
    }
    
    var executionStatus: Status? {
        Status(rawValue: status)
    }
}

// MARK: - Step Results
extension ExecutionHistory {
    
    struct StepResult: Codable {
        let stepName: String
        let output: String
        let duration: Double
    }
    
    var stepResults: [StepResult] {
        guard let data = stepResultsJSON.data(using: .utf8),
              let results = try? JSONDecoder().decode([StepResult].self, from: data) else {
            return []
        }
        return results
    }
    
    func setStepResults(_ results: [StepResult]) {
        if let data = try? JSONEncoder().encode(results),
           let json = String(data: data, encoding: .utf8) {
            self.stepResultsJSON = json
        }
    }
}
