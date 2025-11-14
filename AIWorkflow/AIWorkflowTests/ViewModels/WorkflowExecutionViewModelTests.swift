//
//  WorkflowExecutionViewModelTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 14.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("WorkflowExecutionViewModel Tests")
@MainActor
struct WorkflowExecutionViewModelTests {
    
    // MARK: - Mock Services
    
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
                
                try? await Task.sleep(nanoseconds: 50_000_000)
                
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
    
    @Test("ViewModel initializes correctly")
    func testInitialization() {
        let workflow = Workflow(name: "Test")
        let engine = MockExecutionEngine()
        let history = MockHistoryRepository()
        
        let viewModel = WorkflowExecutionViewModel(
            workflow: workflow,
            executionEngine: engine,
            historyRepository: history
        )
        
        #expect(viewModel.workflow.name == "Test")
        #expect(viewModel.inputText.isEmpty)
        #expect(viewModel.isExecuting == false)
        #expect(viewModel.completedSteps.isEmpty)
    }
    
    @Test("canExecute is false with empty input")
    func testCanExecuteEmptyInput() {
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let engine = MockExecutionEngine()
        let history = MockHistoryRepository()
        
        let viewModel = WorkflowExecutionViewModel(
            workflow: workflow,
            executionEngine: engine,
            historyRepository: history
        )
        
        viewModel.inputText = ""
        #expect(viewModel.canExecute == false)
    }
    
    @Test("canExecute is true with valid input")
    func testCanExecuteValidInput() {
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let engine = MockExecutionEngine()
        let history = MockHistoryRepository()
        
        let viewModel = WorkflowExecutionViewModel(
            workflow: workflow,
            executionEngine: engine,
            historyRepository: history
        )
        
        viewModel.inputText = "Test input"
        #expect(viewModel.canExecute == true)
    }
    
    @Test("Execute workflow succeeds")
    func testExecuteSuccess() async {
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let engine = MockExecutionEngine()
        let history = MockHistoryRepository()
        
        let viewModel = WorkflowExecutionViewModel(
            workflow: workflow,
            executionEngine: engine,
            historyRepository: history
        )
        
        viewModel.inputText = "Test input"
        await viewModel.execute()
        
        #expect(engine.executeCalled)
        #expect(viewModel.executionResult != nil)
        #expect(viewModel.executionResult?.status == .success)
        #expect(history.saveCalled)
    }
    
    @Test("Execute workflow handles failure")
    func testExecuteFailure() async {
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let engine = MockExecutionEngine()
        engine.shouldFail = true
        let history = MockHistoryRepository()
        
        let viewModel = WorkflowExecutionViewModel(
            workflow: workflow,
            executionEngine: engine,
            historyRepository: history
        )
        
        viewModel.inputText = "Test input"
        await viewModel.execute()
        
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Cancel calls engine cancel")
    func testCancel() async {
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let engine = MockExecutionEngine()
        let history = MockHistoryRepository()
        
        let viewModel = WorkflowExecutionViewModel(
            workflow: workflow,
            executionEngine: engine,
            historyRepository: history
        )
        
        viewModel.inputText = "hello"
        
        let task = Task {
            await viewModel.execute()
        }
        
        try? await Task.sleep(nanoseconds: 10_000_000)  // 10ms → execution başlıyor

        viewModel.cancel()
        
        #expect(engine.cancelCalled) // artık true
        
        task.cancel()
    }
    
    @Test("Reset clears state")
    func testReset() async {
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let engine = MockExecutionEngine()
        let history = MockHistoryRepository()
        
        let viewModel = WorkflowExecutionViewModel(
            workflow: workflow,
            executionEngine: engine,
            historyRepository: history
        )
        
        viewModel.inputText = "Test input"
        await viewModel.execute()
        
        #expect(viewModel.executionResult != nil)
        
        viewModel.reset()
        
        #expect(viewModel.inputText.isEmpty)
        #expect(viewModel.completedSteps.isEmpty)
        #expect(viewModel.executionResult == nil)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Progress calculates correctly")
    func testProgress() async {
        let workflow = Workflow(name: "Test")
        let step1 = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        let step2 = WorkflowStep(stepType: "translate", prompt: "Test", order: 1)
        step1.workflow = workflow
        step2.workflow = workflow
        workflow.steps = [step1, step2]
        
        let engine = MockExecutionEngine()
        let history = MockHistoryRepository()
        
        let viewModel = WorkflowExecutionViewModel(
            workflow: workflow,
            executionEngine: engine,
            historyRepository: history
        )
        
        viewModel.inputText = "Test input"
        
        #expect(viewModel.progress == 0.0)
        
        await viewModel.execute()
        
        #expect(viewModel.progress == 1.0)
    }
}
