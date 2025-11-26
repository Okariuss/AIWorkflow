//
//  WorkflowModelTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("Workflow Model Tests")
struct WorkflowModelTests {
    
    @Test("Workflow initializes with correct default values")
    func testWorkflowInitialization() {
        let workflow = Workflow(name: "Test Workflow")
        
        #expect(workflow.name == "Test Workflow")
        #expect(workflow.workflowDescription == "")
        #expect(workflow.isFavorite == false)
        #expect(workflow.steps.isEmpty)
        #expect(workflow.stepCount == 0)
        #expect(workflow.hasSteps == false)
    }
    
    @Test("Workflow step count updates correctly")
    func testWorkflowStepCount() {
        let workflow = Workflow(name: "Test Workflow")
        let step1 = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        let step2 = WorkflowStep(stepType: "translate", prompt: "Test", order: 1)
        
        workflow.steps = [step1, step2]
        
        #expect(workflow.stepCount == 2)
        #expect(workflow.hasSteps == true)
    }
    
    @Test("Workflow sorts steps by order")
    func testWorkflowSortedSteps() {
        let workflow = Workflow(name: "Test Workflow")
        let step1 = WorkflowStep(stepType: "summarize", prompt: "First", order: 0)
        let step2 = WorkflowStep(stepType: "translate", prompt: "Second", order: 1)
        let step3 = WorkflowStep(stepType: "analyze", prompt: "Third", order: 2)
        
        workflow.steps = [step3, step1, step2]
        
        let sortedSteps = workflow.sortedSteps
        
        #expect(sortedSteps[0].order == 0)
        #expect(sortedSteps[1].order == 1)
        #expect(sortedSteps[2].order == 2)
    }
}
