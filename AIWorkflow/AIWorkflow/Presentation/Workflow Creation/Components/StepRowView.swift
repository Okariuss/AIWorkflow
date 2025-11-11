//
//  StepRowView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct StepRowView: View {
    
    // MARK: - Properties
    let step: WorkflowStep
    let index: Int
    
    // MARK: - View
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index + 1)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(.blue))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: iconForStepType)
                        .foregroundStyle(.blue)
                    
                    Text(stepTypeDisplayName)
                        .font(.headline)
                    
                    Spacer()
                }
                
                Text(step.prompt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Computed Properties
private extension StepRowView {
    var iconForStepType: String {
        guard let type = WorkflowStep.StepType(rawValue: step.stepType) else {
            return "wand.and.stars"
        }
        
        switch type {
        case .summarize: return "doc.text"
        case .translate: return "globe"
        case .extract: return "magnifyingglass"
        case .rewrite: return "pencil.line"
        case .analyze: return "chart.bar"
        case .custom: return "wand.and.stars"
        }
    }
    
    var stepTypeDisplayName: String {
        WorkflowStep.StepType(rawValue: step.stepType)?.rawValue ?? step.stepType
    }
}

#Preview {
    List {
        StepRowView(
            step: WorkflowStep(
                stepType: WorkflowStep.StepType.summarize.rawValue,
                prompt: "Summarize the following text in 3 sentences",
                order: 0
            ),
            index: 0
        )
        
        StepRowView(
            step: WorkflowStep(
                stepType: WorkflowStep.StepType.translate.rawValue,
                prompt: "Translate to Spanish",
                order: 1
            ),
            index: 1
        )
        
        StepRowView(
            step: WorkflowStep(
                stepType: WorkflowStep.StepType.extract.rawValue,
                prompt: "Extract all email addresses",
                order: 2
            ),
            index: 2
        )
    }
}
