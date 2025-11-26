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
    var selectedStepType: WorkflowStep.StepType = .custom
    var prompt = ""
    
    // Advanced Options
    var showAdvancedOptions = false
    var useAdvancedOptions = false
    var temperature: Double = 0.7
    var maxTokens: Int = 500
    var samplingMode: WorkflowStep.AdvancedOptions.SamplingMode = .random
    
    // Testing
    var isTestingStep = false
    var testInput = ""
    var testOutput = ""
    var testError: String?
    
    private(set) var validationError: String?
    
    // Foundation Models API supports GenerationOptions with temperature (0.0-2.0)
    var isValid: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        prompt.count >= 3 &&
        (temperature >= 0 && temperature <= 2.0) &&
        (maxTokens > 0 && maxTokens <= 4096)
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
    private let aiService: FoundationModelsService
    
    init(existingStep: WorkflowStep? = nil, aiService: FoundationModelsService? = nil) {
        self.existingStep = existingStep
        self.aiService = aiService ?? .shared
        
        if let step = existingStep {
            self.selectedStepType = WorkflowStep.StepType(rawValue: step.stepType) ?? .custom
            self.prompt = step.prompt
            
            let options = step.advancedOptions
            self.useAdvancedOptions = options.useAdvancedOptions
            self.temperature = options.temperature
            self.maxTokens = options.maxTokens
            self.samplingMode = options.samplingMode
        }
    }
}

// MARK: - Public Methods
extension StepConfigurationViewModel {
    func validate() -> Bool {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedPrompt.isEmpty {
            validationError = L10N.StepConfig.Validation.empty
            return false
        }
        
        if trimmedPrompt.count < 3 {
            validationError = L10N.StepConfig.Validation.short
            return false
        }
        
        if useAdvancedOptions {
            if temperature < 0 || temperature > 2.0 {
                validationError = L10N.StepConfig.Validation.temperature
                return false
            }
            
            if maxTokens < 1 || maxTokens > 4096 {
                validationError = L10N.StepConfig.Validation.tokens
                return false
            }
        }
        
        validationError = nil
        return true
    }
    
    func createStep(order: Int) -> WorkflowStep {
        let step: WorkflowStep
        
        if let existing = existingStep {
            existing.stepType = selectedStepType.rawValue
            existing.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.order = order
            step = existing
        } else {
            step = WorkflowStep(
                stepType: selectedStepType.rawValue,
                prompt: prompt.trimmingCharacters(in: .whitespacesAndNewlines),
                order: order
            )
        }
        
        let options = WorkflowStep.AdvancedOptions(
            temperature: temperature,
            maxTokens: maxTokens,
            samplingMode: samplingMode,
            useAdvancedOptions: useAdvancedOptions
        )
        step.updateAdvancedOptions(options)
        
        return step
    }
    
    // MARK: - Test Step
    func testStep() async {
        guard !testInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            testError = L10N.StepConfig.Validation.testInput
            return
        }
        
        isTestingStep = true
        testOutput = ""
        testError = nil
        
        do {
            guard await aiService.isAvailable() else {
                throw AIServiceError.modelNotAvailable
            }
            
            let fullTestPrompt = "\(fullPrompt)\n\n\(testInput)"
            
            if useAdvancedOptions {
                // Use advanced options for test
                let output = try await aiService.executeWithOptions(
                    prompt: fullTestPrompt,
                    temperature: temperature,
                    maxTokens: maxTokens,
                    samplingMode: samplingMode
                )
                testOutput = output
            } else {
                // Use default options
                let output = try await aiService.execute(prompt: fullTestPrompt)
                testOutput = output
            }
            
        } catch {
            testError = error.localizedDescription
        }
        
        isTestingStep = false
    }
    
    func clearTest() {
        testInput = ""
        testOutput = ""
        testError = nil
    }
    
    func clearError() {
        validationError = nil
    }
    
    // MARK: - Advanced Options Helpers
    func resetAdvancedOptions() {
        temperature = 0.7
        maxTokens = 500
        samplingMode = .random
        useAdvancedOptions = false
    }
}
