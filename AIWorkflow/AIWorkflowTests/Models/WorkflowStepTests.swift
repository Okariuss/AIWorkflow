//
//  WorkflowStepTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("WorkflowStep Model Tests")
struct WorkflowStepTests {
    
    @Test("WorkflowStep initializas correctly")
    func testWorkflowStepInitialization() {
        let step = WorkflowStep(
            stepType: WorkflowStep.StepType.summarize.rawValue,
            prompt: "Summarize this text",
            order: 0
        )
        
        #expect(step.stepType == WorkflowStep.StepType.summarize.rawValue)
        #expect(step.prompt == "Summarize this text")
        #expect(step.order == 0)
        #expect(step.workflow == nil)
    }
    
    @Test("Step types have correct system prompts")
    func testStepTypeSystemPrompts() {
        #expect(WorkflowStep.StepType.summarize.systemPrompt == L10N.StepType.summarizeSystemPrompt)
        #expect(WorkflowStep.StepType.translate.systemPrompt == L10N.StepType.translateSystemPrompt)
        #expect(WorkflowStep.StepType.extract.systemPrompt == L10N.StepType.extractSystemPrompt)
    }
    
    @Test("All step types are available")
    func testAllStepTypes() {
        let allTypes = WorkflowStep.StepType.allCases
        #expect(allTypes.count == 6)
        #expect(allTypes.contains(.summarize))
        #expect(allTypes.contains(.translate))
        #expect(allTypes.contains(.extract))
        #expect(allTypes.contains(.rewrite))
        #expect(allTypes.contains(.analyze))
        #expect(allTypes.contains(.custom))
    }
}
