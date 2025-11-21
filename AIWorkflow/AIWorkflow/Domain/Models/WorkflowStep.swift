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
    var advancedOptionsJSON: String
    
    init(
        id: UUID = UUID(),
        stepType: String,
        prompt: String,
        order: Int,
        workflow: Workflow? = nil,
        advancedOptionsJSON: String = ""
    ) {
        self.id = id
        self.stepType = stepType
        self.prompt = prompt
        self.order = order
        self.workflow = workflow
        self.advancedOptionsJSON = advancedOptionsJSON
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
        
        var icon: String {
            switch self {
            case .summarize: return "doc.text"
            case .translate: return "globe"
            case .extract: return "magnifyingglass"
            case .rewrite: return "pencil.line"
            case .analyze: return "chart.bar"
            case .custom: return "wand.and.stars"
            }
        }
    }
}

// MARK: - Advanced Options
extension WorkflowStep {
    
    struct AdvancedOptions: Codable {
        var temperature: Double
        var maxTokens: Int
        var samplingMode: SamplingMode
        var useAdvancedOptions: Bool
        
        static let `default` = AdvancedOptions(
            temperature: 0.7,
            maxTokens: 500,
            samplingMode: .random,
            useAdvancedOptions: false
        )
        
        enum SamplingMode: String, Codable, CaseIterable {
            case greedy = "Greedy"
            case random = "Random"
            
            var description: String {
                switch self {
                case .greedy: return "Deterministic (same output for same input)"
                case .random: return "Creative (varied outputs)"
                }
            }
        }
    }
    
    @MainActor
    var advancedOptions: AdvancedOptions {
        get {
            guard !advancedOptionsJSON.isEmpty,
                  let data = advancedOptionsJSON.data(using: .utf8),
                  let options = try? JSONDecoder().decode(AdvancedOptions.self, from: data) else {
                return .default
            }
            return options
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                advancedOptionsJSON = json
            }
        }
    }
    
    @MainActor
    func updateAdvancedOptions(_ options: AdvancedOptions) {
        self.advancedOptions = options
    }
}
