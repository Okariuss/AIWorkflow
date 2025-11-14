//
//  WorkflowExecutionViewModel.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 14.11.2025.
//

import Foundation
import UIKit

@MainActor
@Observable
final class WorkflowExecutionViewModel {
    // MARK: - Published State
    let workflow: Workflow
    
    var inputText = ""
    
    private(set) var isExecuting = false
    private(set) var currentStep: WorkflowStep?
    private(set) var currentStepIndex = 0
    private(set) var currentOutput = ""
    private(set) var completedSteps: [StepExecutionResult] = []
    private(set) var executionResult: WorkflowExecutionResult?
    private(set) var errorMessage: String?
    
    var progress: Double {
        guard workflow.hasSteps else { return 0 }
        return Double(completedSteps.count) / Double(workflow.stepCount)
    }
    
    var canExecute: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        workflow.hasSteps &&
        !isExecuting
    }
    
    var canCancel: Bool {
        isExecuting
    }
    
    private let haptics = UINotificationFeedbackGenerator()
    
    // MARK: - Dependencies
    private let executionEngine: WorkflowExecutionEngineProtocol
    private let historyRepository: ExecutionHistoryRepositoryProtocol
    
    // MARK: - Init
    init(
        workflow: Workflow,
        executionEngine: WorkflowExecutionEngineProtocol,
        historyRepository: ExecutionHistoryRepositoryProtocol
    ) {
        self.workflow = workflow
        self.executionEngine = executionEngine
        self.historyRepository = historyRepository
    }
}

// MARK: - Public Methods
extension WorkflowExecutionViewModel {
    func execute() async {
        guard canExecute else { return }
        isExecuting = true
        resetState()
        
        do {
            let result = try await executionEngine.executeStreaming(
                workflow: workflow,
                input: inputText,
                onStepStart: { [weak self] step in
                    self?.handleStepStart(step)
                },
                onStepProgress: { [weak self] step, output in
                    self?.handleStepProgress(step, output: output)
                },
                onStepComplete: { [weak self] result in
                    self?.handleStepComplete(result)
                }
            )
            executionResult = result
            
            if result.status == .success {
                haptics.notificationOccurred(.success)
            } else if result.status == .failed {
                haptics.notificationOccurred(.error)
            }
            
            await saveToHistory(result)
            
        } catch {
            if let execError = error as? WorkflowExecutionError {
                errorMessage = execError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            
            if !completedSteps.isEmpty {
                executionResult = WorkflowExecutionResult(
                    workflow: workflow,
                    inputText: inputText,
                    finalOutput: completedSteps.last?.output ?? "",
                    stepResults: completedSteps,
                    totalDuration: completedSteps.reduce(0) { $0 + $1.duration },
                    startedAt: completedSteps.first?.startedAt ?? Date(),
                    completedAt: Date(),
                    status: .failed,
                    error: errorMessage
                )
                
                if let result = executionResult {
                    await saveToHistory(result)
                }
            }
        }
        
        isExecuting = false
        currentStep = nil
    }
    
    func cancel() {
        guard canCancel else { return }
        executionEngine.cancel()
    }
    
    func reset() {
        inputText = ""
        currentStep = nil
        resetState()
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Private Methods
private extension WorkflowExecutionViewModel {
    func resetState() {
        currentStepIndex = 0
        currentOutput = ""
        completedSteps = []
        executionResult = nil
        errorMessage = nil
    }
    
    func handleStepStart(_ step: WorkflowStep) {
        currentStep = step
        currentStepIndex = completedSteps.count
        currentOutput = ""
    }
    
    func handleStepProgress(_ step: WorkflowStep, output: String) {
        currentOutput = output
    }
    
    func handleStepComplete(_ result: StepExecutionResult) {
        completedSteps.append(result)
        currentOutput = result.output
        
        if result.isSuccess {
            haptics.notificationOccurred(.success)
        } else {
            haptics.notificationOccurred(.error)
        }
    }
    
    func saveToHistory(_ result: WorkflowExecutionResult) async {
        let stepResults = result.stepResults.map { stepResult in
            ExecutionHistory.StepResult(
                stepName: stepResult.step.stepType,
                output: stepResult.output,
                duration: stepResult.duration
            )
        }
        
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
        
        history.setStepResults(stepResults)
        
        do {
            try await historyRepository.save(history)
        } catch {
            print("Failed to save execution history: \(error)")
        }
    }
}
