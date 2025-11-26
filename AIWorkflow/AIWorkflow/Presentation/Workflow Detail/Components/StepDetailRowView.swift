//
//  StepDetailRowView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct StepDetailRowView: View {
    
    // MARK: - Properties
    let step: WorkflowStep
    let index: Int
    
    @State private var isExpanded = false
    
    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerSubview
            
            if isExpanded {
                expandedContent
            }
        }
    }
}

// MARK: - Subviews
private extension StepDetailRowView {
    var stepNumberBadge: some View {
        ZStack {
            Circle()
                .fill(.blue.gradient)
                .frame(width: 32, height: 32)
            
            Text("\(index + 1)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
    
    var headerSubview: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                stepNumberBadge
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: iconForStepType)
                            .foregroundStyle(.blue)
                            .font(.subheadline)
                        
                        Text(stepTypeDisplayName)
                            .font(.headline)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !isExpanded {
                        Text(step.prompt)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 12)
    }
    
    var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Label(L10N.WorkflowDetail.prompt, systemImage: "text.quote")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(step.prompt)
                    .font(.body)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            if !systemPrompt.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label(L10N.StepConfig.typeFooter, systemImage: "cpu")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(systemPrompt)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.quaternary.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.bottom, 12)
    }
    
    var stepTypeDisplayName: String {
        WorkflowStep.StepType(rawValue: step.stepType)?.title ?? step.stepType
    }
    
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
    
    var systemPrompt: String {
        WorkflowStep.StepType(rawValue: step.stepType)?.systemPrompt ?? ""
    }
}

#Preview {
    List {
        StepDetailRowView(
            step: WorkflowStep(
                stepType: WorkflowStep.StepType.summarize.rawValue,
                prompt: "Summarize the following text in exactly 3 sentences, focusing on the main points.",
                order: 0
            ),
            index: 0
        )
        
        StepDetailRowView(
            step: WorkflowStep(
                stepType: WorkflowStep.StepType.translate.rawValue,
                prompt: "Translate the summary to Spanish",
                order: 1
            ),
            index: 1
        )
        
        StepDetailRowView(
            step: WorkflowStep(
                stepType: WorkflowStep.StepType.extract.rawValue,
                prompt: "Extract all email addresses and phone numbers",
                order: 2
            ),
            index: 2
        )
    }
}
