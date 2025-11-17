//
//  WorkflowExecutionService.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 17.11.2025.
//

import Foundation
import ActivityKit

@MainActor
final class WorkflowExecutionService {
    // MARK: - Dependencies
    private let executionEngine: WorkflowExecutionEngineProtocol
    private let historyRepository: ExecutionHistoryRepositoryProtocol
    private let liveActivityManager: LiveActivityManager
    
    // MARK: Init
    init(
        executionEngine: WorkflowExecutionEngineProtocol,
        historyRepository: ExecutionHistoryRepositoryProtocol,
        liveActivityManager: LiveActivityManager? = nil
    ) {
        self.executionEngine = executionEngine
        self.historyRepository = historyRepository
        self.liveActivityManager = liveActivityManager ?? .shared
    }
}

// MARK: - Public Methods
extension WorkflowExecutionService {
    func executeWorkflow(
        workflow: Workflow,
        inputText: String,
        enableLiveActivity: Bool = true,
        onStepStart: ((WorkflowStep) -> Void)? = nil,
        onStepProgress: ((WorkflowStep, String) -> Void)? = nil,
        onStepComplete: ((StepExecutionResult) -> Void)? = nil
    ) async throws -> WorkflowExecutionResult {
        
        guard workflow.hasSteps else {
            throw WorkflowExecutionError.noSteps
        }
        
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WorkflowExecutionError.emptyInput
        }
        
        let executionStartTime = Date()
        var stepResults: [StepExecutionResult] = []
        var currentStepIndex = 0
        
        if enableLiveActivity {
            if liveActivityManager.areActivitiesEnabled() {
                try? await liveActivityManager.startActivity(
                    workflowName: workflow.name,
                    workflowId: workflow.id,
                    totalSteps: workflow.stepCount
                )
            }
        }
        
        do {
            let result = try await executionEngine.executeStreaming(
                workflow: workflow,
                input: inputText,
                onStepStart: { [weak self] step in
                    guard let self else { return }
                    
                    if enableLiveActivity {
                        Task {
                            let elapsedTime = Date().timeIntervalSince(executionStartTime)
                            await self.liveActivityManager.updateActivity(
                                currentStepIndex: currentStepIndex,
                                currentStepName: step.stepType,
                                currentOutput: "",
                                progress: Double(currentStepIndex) / Double(workflow.stepCount),
                                elapsedTime: elapsedTime
                            )
                        }
                    }
                    
                    onStepStart?(step)
                },
                onStepProgress: { [weak self] step, output in
                    guard let self = self else { return }
                    
                    if enableLiveActivity {
                        Task {
                            let elapsedTime = Date().timeIntervalSince(executionStartTime)
                            await self.liveActivityManager.updateActivity(
                                currentStepIndex: currentStepIndex,
                                currentStepName: step.stepType,
                                currentOutput: String(output.prefix(100)),
                                progress: Double(currentStepIndex) / Double(workflow.stepCount),
                                elapsedTime: elapsedTime
                            )
                        }
                    }
                    
                    onStepProgress?(step, output)
                },
                onStepComplete: { stepResult in
                    stepResults.append(stepResult)
                    currentStepIndex += 1
                    
                    onStepComplete?(stepResult)
                }
            )
            if enableLiveActivity {
                let elapsedTime = Date().timeIntervalSince(executionStartTime)
                await liveActivityManager.endActivity(
                    finalOutput: result.finalOutput,
                    status: .completed,
                    elapsedTime: elapsedTime
                )
            }
            
            await saveToHistory(
                workflow: workflow,
                result: result,
                stepResults: stepResults
            )
            
            return result
        } catch {
            if enableLiveActivity {
                let elapsedTime = Date().timeIntervalSince(executionStartTime)
                await liveActivityManager.endActivity(
                    finalOutput: error.localizedDescription,
                    status: .failed,
                    elapsedTime: elapsedTime
                )
            }
            
            if !stepResults.isEmpty {
                let failedResult = WorkflowExecutionResult(
                    workflow: workflow,
                    inputText: inputText,
                    finalOutput: stepResults.last?.output ?? "",
                    stepResults: stepResults,
                    totalDuration: Date().timeIntervalSince(executionStartTime),
                    startedAt: executionStartTime,
                    completedAt: Date(),
                    status: .failed,
                    error: error.localizedDescription
                )
                
                await saveToHistory(
                    workflow: workflow,
                    result: failedResult,
                    stepResults: stepResults
                )
            }
            
            throw error
        }
    }
    
    func cancelExecution() {
        executionEngine.cancel()
        
        Task {
            await liveActivityManager.cancelActivity()
        }
    }
}

// MARK: Private Methods
private extension WorkflowExecutionService {
    func saveToHistory(
        workflow: Workflow,
        result: WorkflowExecutionResult,
        stepResults: [StepExecutionResult]
    ) async {
        let history = ExecutionHistory(
            workflowId: workflow.id,
            workflowName: workflow.name,
            executedAt: result.startedAt,
            duration: result.totalDuration,
            status: result.status.rawValue,
            inputText: result.inputText,
            outputText: result.finalOutput,
            stepResultsJSON: ""
        )
        
        let stepResultsForHistory = stepResults.map { stepResult in
            ExecutionHistory.StepResult(
                stepName: stepResult.step.stepType,
                output: stepResult.output,
                duration: stepResult.duration
            )
        }
        history.setStepResults(stepResultsForHistory)
        
        do {
            try await historyRepository.save(history)
        } catch {
            print("❌ Failed to save execution history: \(error)")
        }
    }
}

