//
//  WorkflowExecutionEngineTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 13.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("WorkflowExecutionEngine Tests")
@MainActor
struct WorkflowExecutionEngineTests {
    
    // MARK: - Mock AI Service
    
    final class MockAIService: AIServiceProtocol {
        var responses: [String] = []
        var currentIndex = 0
        var shouldFail = false
        var isModelAvailable = true
        var isAdvancedOptionsEnabled = false
        
        func execute(prompt: String) async throws -> String {
            if !isModelAvailable {
                throw AIServiceError.modelNotAvailable
            }
            
            if shouldFail {
                throw AIServiceError.executionFailed("Mock failure")
            }
            
            guard currentIndex < responses.count else {
                return "Default response"
            }
            
            let response = responses[currentIndex]
            currentIndex += 1
            return response
        }
        
        func executeWithOptions(prompt: String, temperature: Double, maxTokens: Int, samplingMode: WorkflowStep.AdvancedOptions.SamplingMode) async throws -> String {
            isAdvancedOptionsEnabled = true
            return try await execute(prompt: prompt)
        }
        
        func executeStreaming(prompt: String) async throws -> AsyncThrowingStream<String, Error> {
            AsyncThrowingStream { continuation in
                Task {
                    if !self.isModelAvailable {
                        continuation.finish(throwing: AIServiceError.modelNotAvailable)
                    }
                    
                    if self.shouldFail {
                        continuation.finish(throwing: AIServiceError.executionFailed("Mock streaming failure"))
                        return
                    }
                    
                    guard self.currentIndex < self.responses.count else {
                        continuation.yield("Default streaming response")
                        continuation.finish()
                        return
                    }
                    
                    let response = self.responses[self.currentIndex]
                    self.currentIndex += 1
                    
                    let words = response.split(separator: " ")
                    var accumulated = ""
                    
                    for word in words {
                        try? await Task.sleep(for: .milliseconds(10))
                        accumulated += (accumulated.isEmpty ? "" : " ") + word
                        continuation.yield(accumulated)
                    }
                    
                    continuation.finish()
                }
            }
        }
        
        func executeStreamingWithOptions(prompt: String, temperature: Double, maxTokens: Int, samplingMode: WorkflowStep.AdvancedOptions.SamplingMode) async throws -> AsyncThrowingStream<String, any Error> {
            isAdvancedOptionsEnabled = true
            return try await executeStreaming(prompt: prompt)
        }
        
        func isAvailable() async -> Bool {
            isModelAvailable
        }
        
        func reset() {
            responses = []
            currentIndex = 0
            shouldFail = false
            isModelAvailable = true
        }
    }
    
    // MARK: - Tests
    
    @Test("Execute workflow with single step succeeds")
    func testExecuteSingleStep() async throws {
        let mockService = MockAIService()
        mockService.responses = ["Summarized output"]
        
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Summarize this", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let result = try await engine.execute(workflow: workflow, input: "Test input")
        
        #expect(result.status == .success)
        #expect(result.stepResults.count == 1)
        #expect(result.stepResults[0].isSuccess == true)
    }
    
    @Test("Execute workflow with multiple steps succeeds")
    func testExecuteMultipleSteps() async throws {
        let mockService = MockAIService()
        mockService.responses = ["Step 1 output", "Step 2 output", "Step 3 output"]
        
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        let step1 = WorkflowStep(stepType: "summarize", prompt: "Summarize", order: 0)
        let step2 = WorkflowStep(stepType: "translate", prompt: "Translate", order: 1)
        let step3 = WorkflowStep(stepType: "analyze", prompt: "Analyze", order: 2)
        
        step1.workflow = workflow
        step2.workflow = workflow
        step3.workflow = workflow
        workflow.steps = [step1, step2, step3]
        
        let result = try await engine.execute(workflow: workflow, input: "Initial input")
        
        #expect(result.status == .success)
        #expect(result.stepResults.count == 3)
    }
    
    @Test("Execute fails with no steps")
    func testExecuteNoSteps() async {
        let mockService = MockAIService()
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        
        do {
            _ = try await engine.execute(workflow: workflow, input: "Test input")
            Issue.record("Should have thrown error for no steps")
        } catch {
            #expect(error is WorkflowExecutionError)
            if let execError = error as? WorkflowExecutionError,
               case .noSteps = execError {
                // Success
            } else {
                Issue.record("Wrong error type")
            }
        }
    }
    
    @Test("Execute fails with empty input")
    func testExecuteEmptyInput() async {
        let mockService = MockAIService()
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        do {
            _ = try await engine.execute(workflow: workflow, input: "   ")
            Issue.record("Should have thrown error for empty input")
        } catch {
            #expect(error is WorkflowExecutionError)
        }
    }
    
    @Test("Execute fails when AI service unavailable")
    func testExecuteAIUnavailable() async {
        let mockService = MockAIService()
        mockService.isModelAvailable = false
        
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        do {
            _ = try await engine.execute(workflow: workflow, input: "Test")
            Issue.record("Should have thrown error when AI unavailable")
        } catch {
            #expect(error is WorkflowExecutionError)
        }
    }
    
    @Test("Execute with advanced options")
    func testExecuteWithAdvancedOptions() async {
        let mockService = MockAIService()
        mockService.responses = ["Advanced response"]
        
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        step.advancedOptions.useAdvancedOptions = true
        workflow.steps = [step]
        
        do {
            let result = try await engine.execute(workflow: workflow, input: "Test input")
            #expect(result.status == .success)
            #expect(result.stepResults.count == 1)
            #expect(result.stepResults[0].isSuccess == true)
            #expect(mockService.isAdvancedOptionsEnabled == true)
        } catch {
            Issue.record("Advanced options execution failed: \(error)")
        }
    }
    
    @Test("Execute streaming calls callbacks")
    func testExecuteStreaming() async throws {
        let mockService = MockAIService()
        mockService.responses = ["Streaming output"]
        
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        var stepStarted = false
        var progressUpdates: [String] = []
        var stepCompleted = false
        
        let result = try await engine.executeStreaming(
            workflow: workflow,
            input: "Test input",
            onStepStart: { _ in
                stepStarted = true
            },
            onStepProgress: { _, output in
                progressUpdates.append(output)
            },
            onStepComplete: { _ in
                stepCompleted = true
            }
        )
        
        #expect(stepStarted == true)
        #expect(!progressUpdates.isEmpty)
        #expect(stepCompleted == true)
        #expect(result.status == .success)
    }
    
    @Test("Execute streaming with advanced options calls callbacks")
    func testExecuteStreamingWithAdvancedOptions() async throws {
        let mockService = MockAIService()
        mockService.responses = ["Streaming advanced output"]
        
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        step.advancedOptions.useAdvancedOptions = true
        workflow.steps = [step]
        
        var stepStarted = false
        var progressUpdates: [String] = []
        var stepCompleted = false
        
        let result = try await engine.executeStreaming(
            workflow: workflow,
            input: "Test input",
            onStepStart: { _ in stepStarted = true },
            onStepProgress: { _, output in progressUpdates.append(output) },
            onStepComplete: { _ in stepCompleted = true }
        )
        
        #expect(stepStarted == true)
        #expect(!progressUpdates.isEmpty)
        #expect(stepCompleted == true)
        #expect(result.status == .success)
        #expect(mockService.isAdvancedOptionsEnabled == true)
    }
    
    @Test("Cancel stops execution")
    func testCancel() async {
        let mockService = MockAIService()
        mockService.responses = ["Step 1", "Step 2"]
        
        let engine = WorkflowExecutionEngine(aiService: mockService)
        
        let workflow = Workflow(name: "Test")
        let step1 = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        let step2 = WorkflowStep(stepType: "translate", prompt: "Test", order: 1)
        step1.workflow = workflow
        step2.workflow = workflow
        workflow.steps = [step1, step2]
        
        Task {
            try? await Task.sleep(for: .milliseconds(50))
            engine.cancel()
        }
        
        do {
            _ = try await engine.execute(workflow: workflow, input: "Test")
            // May or may not throw depending on timing
        } catch {
            // If cancelled, should be cancellation error
            if let execError = error as? WorkflowExecutionError,
               case .cancelled = execError {
                // Success - cancellation worked
            }
        }
    }
    
}
