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
        case summarize
        case translate
        case extract
        case rewrite
        case analyze
        case custom
        
        var title: String {
            switch self {
            case .summarize: L10N.StepType.summarize
            case .translate: L10N.StepType.translate
            case .extract: L10N.StepType.extract
            case .rewrite: L10N.StepType.rewrite
            case .analyze: L10N.StepType.analyze
            case .custom: L10N.StepType.custom
            }
        }
        
        var systemPrompt: String {
            switch self {
            case .summarize: L10N.StepType.summarizeSystemPrompt
            case .translate: L10N.StepType.translateSystemPrompt
            case .extract: L10N.StepType.extractSystemPrompt
            case .rewrite: L10N.StepType.rewriteSystemPrompt
            case .analyze: L10N.StepType.analyzeSystemPrompt
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
            
            var title: String {
                switch self {
                case .greedy: L10N.WorkflowStep.Advanced.greedy
                case .random: L10N.WorkflowStep.Advanced.random
                }
            }
            
            var description: String {
                switch self {
                case .greedy: L10N.WorkflowStep.Advanced.greedyDescription
                case .random: L10N.WorkflowStep.Advanced.randomDescription
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
