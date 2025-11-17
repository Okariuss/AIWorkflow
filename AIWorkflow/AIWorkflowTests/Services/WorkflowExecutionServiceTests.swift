//
//  WorkflowExecutionServiceTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 17.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("WorkflowExecutionService Tests")
@MainActor
struct WorkflowExecutionServiceTests {
    
    // MARK: - Mock Execution Engine
    final class MockExecutionEngine: WorkflowExecutionEngineProtocol {
        var shouldFail = false
        var executeCalled = false
        var cancelCalled = false
        
        func execute(workflow: Workflow, input: String) async throws -> WorkflowExecutionResult {
            executeCalled = true
            
            if shouldFail {
                throw WorkflowExecutionError.stepFailed(stepIndex: 0, error: "Mock failure")
            }
            
            return WorkflowExecutionResult(
                workflow: workflow,
                inputText: input,
                finalOutput: "Mock output",
                stepResults: [],
                totalDuration: 1.0,
                startedAt: Date(),
                completedAt: Date(),
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
            executeCalled = true
            
            if shouldFail {
                throw WorkflowExecutionError.stepFailed(stepIndex: 0, error: "Mock failure")
            }
            
            for step in workflow.sortedSteps {
                onStepStart(step)
                onStepProgress(step, "Mock output")
                
                let result = StepExecutionResult(
                    step: step,
                    output: "Mock output",
                    duration: 0.5,
                    startedAt: Date(),
                    completedAt: Date(),
                    isSuccess: true,
                    error: nil
                )
                
                onStepComplete(result)
            }
            
            return WorkflowExecutionResult(
                workflow: workflow,
                inputText: input,
                finalOutput: "Mock output",
                stepResults: [],
                totalDuration: 1.0,
                startedAt: Date(),
                completedAt: Date(),
                status: .success,
                error: nil
            )
        }
        
        func cancel() {
            cancelCalled = true
        }
    }
    
    // MARK: - Mock History repository
    final class MockHistoryRepository: ExecutionHistoryRepositoryProtocol {
        var histories: [ExecutionHistory] = []
        var saveCalled = false
        
        func fetchAll() async throws -> [ExecutionHistory] {
            histories
        }
        
        func fetch(for workflowId: UUID) async throws -> [ExecutionHistory] {
            histories.filter { $0.workflowId == workflowId }
        }
        
        func save(_ history: ExecutionHistory) async throws {
            saveCalled = true
            histories.append(history)
        }
        
        func delete(_ history: ExecutionHistory) async throws {
            histories.removeAll { $0.id == history.id }
        }
        
        func deleteAll() async throws {
            histories.removeAll()
        }
        
        func fetchRecent(limit: Int) async throws -> [ExecutionHistory] {
            Array(histories.prefix(limit))
        }
    }
    
    
    // MARK: - Tests
    @Test("Service executes workflow successfully")
    func testExecuteWorkflow() async throws {

        let mockEngine = MockExecutionEngine()
        let mockHistory = MockHistoryRepository()
        
        let service = WorkflowExecutionService(
            executionEngine: mockEngine,
            historyRepository: mockHistory
        )
        
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let result = try await service.executeWorkflow(
            workflow: workflow,
            inputText: "Test input",
            enableLiveActivity: false
        )
        
        #expect(result.status == .success)
        #expect(mockEngine.executeCalled)
        #expect(mockHistory.saveCalled)
    }
    
    @Test("Service handles execution errors")
    func testExecuteWorkflowError() async {
        let mockEngine = MockExecutionEngine()
        mockEngine.shouldFail = true
        let mockHistory = MockHistoryRepository()
        
        let service = WorkflowExecutionService(
            executionEngine: mockEngine,
            historyRepository: mockHistory
        )
        
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        do {
            _ = try await service.executeWorkflow(
                workflow: workflow,
                inputText: "Test input",
                enableLiveActivity: false
            )
            Issue.record("Should have thrown error")
        } catch {
            #expect(error is WorkflowExecutionError)
        }
    }
    
    
}
