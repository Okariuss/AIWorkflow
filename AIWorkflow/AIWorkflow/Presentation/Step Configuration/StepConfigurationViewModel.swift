//
//  StepConfigurationViewModel.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import Foundation

@MainActor
@Observable
final class StepConfigurationViewModel {
    
    // MARK: - Published State
    var selectedStepType: WorkflowStep.StepType = .summarize
    var prompt = ""
    
    private(set) var validationError: String?
    
    var isValid: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var fullPrompt: String {
        let systemPrompt = selectedStepType.systemPrompt
        let userPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if systemPrompt.isEmpty {
            return userPrompt
        } else {
            return "\(systemPrompt)\n\n\(userPrompt)"
        }
    }
    
    var getExistingStep: WorkflowStep? {
        existingStep
    }
    
    // MARK: - Dependencies
    private let existingStep: WorkflowStep?
    
    init(existingStep: WorkflowStep? = nil) {
        self.existingStep = existingStep
        
        if let step = existingStep {
            self.selectedStepType = WorkflowStep.StepType(rawValue: step.stepType) ?? .custom
            self.prompt = step.prompt
        }
    }
}

// MARK: - Public Methods
extension StepConfigurationViewModel {
    func validate() -> Bool {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedPrompt.isEmpty {
            validationError = "Prompt cannot be empty"
            return false
        }
        
        if trimmedPrompt.count < 3 {
            validationError = "Prompt must be at least 3 characters long"
            return false
        }
        
        validationError = nil
        return true
    }
    
    func createStep(order: Int) -> WorkflowStep {
        if let existing = existingStep {
            existing.stepType = selectedStepType.rawValue
            existing.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.order = order
            return existing
        } else {
            return WorkflowStep(
                stepType: selectedStepType.rawValue,
                prompt: prompt.trimmingCharacters(in: .whitespacesAndNewlines),
                order: order
            )
        }
    }
    
    func clearError() {
        validationError = nil
    }
}
