//
//  WorkflowExecutionEngine.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 13.11.2025.
//

import Foundation

final class WorkflowExecutionEngine {
    // MARK: - Properties
    private let aiService: AIServiceProtocol
    private var isCancelled = false
    
    // MARK: - Init
    init(aiService: AIServiceProtocol) {
        self.aiService = aiService
    }
}

// MARK: - WorkflowExecutionEngineProtocol
@MainActor
extension WorkflowExecutionEngine: WorkflowExecutionEngineProtocol {
    
    func execute(
        workflow: Workflow,
        input: String
    ) async throws -> WorkflowExecutionResult {
        isCancelled = false
        
        try validateWorkflow(workflow, input: input)
        
        guard await aiService.isAvailable() else {
            throw WorkflowExecutionError.aiServiceUnavailable
        }
        
        let executionStartTime = Date()
        var currentInput = input
        var stepResults: [StepExecutionResult] = []
        
        for (index, step) in workflow.sortedSteps.enumerated() {
            if isCancelled {
                throw WorkflowExecutionError.cancelled
            }
            
            let stepStartTime = Date()
            
            do {
                let prompt = buildPrompt(for: step, with: currentInput)
                let output = try await aiService.execute(prompt: prompt)
                
                let stepEndTime = Date()
                
                let stepResult = StepExecutionResult(
                    step: step,
                    output: output,
                    duration: stepEndTime.timeIntervalSince(stepStartTime),
                    startedAt: stepStartTime,
                    completedAt: stepEndTime,
                    isSuccess: true,
                    error: nil
                )
                stepResults.append(stepResult)
                
                currentInput = output
            } catch {
                let stepEndtime = Date()
                
                let stepResult = StepExecutionResult(
                    step: step,
                    output: "",
                    duration: stepEndtime.timeIntervalSince(stepStartTime),
                    startedAt: stepStartTime,
                    completedAt: stepEndtime,
                    isSuccess: false,
                    error: error.localizedDescription
                )
                
                stepResults.append(stepResult)
                
                throw WorkflowExecutionError.stepFailed(
                    stepIndex: index,
                    error: error.localizedDescription
                )
            }
        }
        
        let executionEndTime = Date()
        
        return WorkflowExecutionResult(
            workflow: workflow,
            inputText: input,
            finalOutput: currentInput,
            stepResults: stepResults,
            totalDuration: executionEndTime.timeIntervalSince(executionStartTime),
            startedAt: executionStartTime,
            completedAt: executionEndTime,
            status: .success,
            error: nil
        )
    }
    
    func executeStreaming(
        workflow: Workflow,
        input: String,
        onStepStart: @escaping (WorkflowStep) -> Void,
        onStepProgress: @escaping (WorkflowStep, String) -> Void,
        onStepComplete: @escaping (StepExecutionResult) -> Void
    ) async throws -> WorkflowExecutionResult {
        isCancelled = false
        
        try validateWorkflow(workflow, input: input)
        
        guard await aiService.isAvailable() else {
            throw WorkflowExecutionError.aiServiceUnavailable
        }
        
        let executionStartTime = Date()
        var currentInput = input
        var stepResults: [StepExecutionResult] = []
        
        for (index, step) in workflow.sortedSteps.enumerated() {
            if isCancelled {
                throw WorkflowExecutionError.cancelled
            }
            
            await MainActor.run {
                onStepStart(step)
            }
            
            let stepStartTime = Date()
            var lastOutput = ""
            
            do {
                let prompt = buildPrompt(for: step, with: currentInput)
                
                for try await snapshot in try await aiService.executeStreaming(prompt: prompt) {
                    if isCancelled {
                        throw WorkflowExecutionError.cancelled
                    }
                    
                    lastOutput = snapshot
                    
                    await MainActor.run {
                        onStepProgress(step, snapshot)
                    }
                }
                
                let stepEndTime = Date()
                
                let stepResult = StepExecutionResult(
                    step: step,
                    output: lastOutput,
                    duration: stepEndTime.timeIntervalSince(stepStartTime),
                    startedAt: stepStartTime,
                    completedAt: stepEndTime,
                    isSuccess: true,
                    error: nil
                )
                
                stepResults.append(stepResult)
                
                await MainActor.run {
                    onStepComplete(stepResult)
                }
                
                currentInput = lastOutput
                
            } catch {
                let stepEndTime = Date()
                
                let stepResult = StepExecutionResult(
                    step: step,
                    output: lastOutput,
                    duration: stepEndTime.timeIntervalSince(stepStartTime),
                    startedAt: stepStartTime,
                    completedAt: stepEndTime,
                    isSuccess: false,
                    error: error.localizedDescription
                )
                
                stepResults.append(stepResult)
                
                await MainActor.run {
                    onStepComplete(stepResult)
                }
                
                throw WorkflowExecutionError.stepFailed(
                    stepIndex: index,
                    error: error.localizedDescription
                )
            }
        }
        
        let executionEndTime = Date()
        
        return WorkflowExecutionResult(
            workflow: workflow,
            inputText: input,
            finalOutput: currentInput,
            stepResults: stepResults,
            totalDuration: executionEndTime.timeIntervalSince(executionStartTime),
            startedAt: executionStartTime,
            completedAt: executionEndTime,
            status: .success,
            error: nil
        )
    }
    
    func cancel() {
        isCancelled = true
    }
}

// MARK: - Private Methods
private extension WorkflowExecutionEngine {
    func validateWorkflow(_ workflow: Workflow, input: String) throws {
        guard workflow.hasSteps else {
            throw WorkflowExecutionError.noSteps
        }
        
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WorkflowExecutionError.emptyInput
        }
    }
    
    func buildPrompt(for step: WorkflowStep, with input: String) -> String {
        guard let stepType = WorkflowStep.StepType(rawValue: step.stepType) else {
            return "\(step.prompt)\n\n\(input)"
        }
        
        let systemPrompt = stepType.systemPrompt
        let userPropmt = step.prompt
        
        if systemPrompt.isEmpty {
            return "\(userPropmt)\n\n\(input)"
        } else {
            return "\(systemPrompt)\n\n\(userPropmt)\n\n\(input)"
        }
    }
}
