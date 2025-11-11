//
//  ExecutionHistoryTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("ExecutionHistory Model Tests")
struct ExecutionHistoryTests {
    
    @Test("ExecutionHistory initializes correctly")
    func testExecutionHistoryInitialization() async throws {
        let workflowId = UUID()
        let history = ExecutionHistory(
            workflowId: workflowId,
            workflowName: "Test Workflow",
            status: ExecutionHistory.Status.success.rawValue,
            inputText: "Input",
            outputText: "Output"
        )
        
        #expect(history.workflowId == workflowId)
        #expect(history.workflowName == "Test Workflow")
        #expect(history.status == "Success")
        #expect(history.executionStatus == .success)
    }
    
    @Test("Step results encode and decode correctly")
    func testStepResultsEncodingDecoding() {
        let history = ExecutionHistory(
            workflowId: UUID(),
            workflowName: "Test",
            status: "Success",
            inputText: "Input",
            outputText: "Output"
        )
        
        let results = [
            ExecutionHistory.StepResult(stepName: "Step 1", output: "Result 1", duration: 1.5),
            ExecutionHistory.StepResult(stepName: "Step 2", output: "Result 2", duration: 2.3)
        ]
        
        history.setStepResults(results)
        let decoded = history.stepResults
        
        #expect(decoded.count == 2)
        #expect(decoded[0].stepName == "Step 1")
        #expect(decoded[1].duration == 2.3)
    }
}
