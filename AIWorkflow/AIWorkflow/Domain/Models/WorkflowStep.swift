//
//  WorkflowStep.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation
import SwiftData

@Model
final class WorkflowStep {
    var id: UUID
    var stepType: String
    var prompt: String
    var order: Int
    var workflow: Workflow?
    
    init(
        id: UUID = UUID(),
        stepType: String,
        prompt: String,
        order: Int,
        workflow: Workflow? = nil
    ) {
        self.id = id
        self.stepType = stepType
        self.prompt = prompt
        self.order = order
        self.workflow = workflow
    }
}

// MARK: - Step Types
extension WorkflowStep {
    
    enum StepType: String, CaseIterable {
        case summarize = "Summarize"
        case translate = "Translate"
        case extract = "Extract Information"
        case rewrite = "Rewrite"
        case analyze = "Analyze"
        case custom = "Custom"
        
        var systemPrompt: String {
            switch self {
            case .summarize: "Summarize the following text concisely:"
            case .translate: "Translate the following text:"
            case .extract: "Extract the requested information from the text:"
            case .rewrite: "Rewrite the following text:"
            case .analyze: "Analyze the following text:"
            case .custom: ""
            }
        }
    }
}
