//
//  StepExecutionRowView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 14.11.2025.
//

import SwiftUI

struct StepExecutionRowView: View {
    
    // MARK: - Properties
    let step: WorkflowStep
    let index: Int
    let status: StepStatus
    let output: String
    let duration: TimeInterval?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            stepBadge
            stepContent
        }
        .padding(.vertical, 8)
    }
    
}

// MARK: - Computed Properties
private extension StepExecutionRowView {
    var badgeColor: Color {
        switch status {
        case .pending: .gray
        case .executing: .blue
        case .completed: .green
        case .failed: .red
        }
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
}

// MARK: - Subviews
private extension StepExecutionRowView {
    @ViewBuilder
    var stepBadge: some View {
        ZStack {
            Circle()
                .fill()
                .frame(width: 32, height: 32)
            
            if status == .executing {
                ProgressView()
                    .controlSize(.small)
                    .tint(.white)
            } else {
                Text("\(index + 1)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
        }
    }
    
    var stepContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            stepTypeAndName
            
            Text(step.prompt)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            
            if !output.isEmpty {
                outputSection
            }
        }
    }
    
    var stepTypeAndName: some View {
        HStack {
            Image(systemName: iconForStepType)
                .foregroundStyle(.blue)
                .font(.subheadline)
            
            Text(stepTypeDisplayName)
                .font(.headline)
            
            Spacer()
            
            statusIndicator
        }
    }
    
    @ViewBuilder
    var statusIndicator: some View {
        switch status {
        case .pending:
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
                .font(.caption)
        case .executing:
            ProgressView()
                .controlSize(.small)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
        }
    }
    
    var outputSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10N.StepConfig.testOutput)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let duration, status == .completed {
                Spacer()
                Text(String(format: "%.2fs", duration))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Text(output)
                .font(.body)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

// MARK: - Step Status
enum StepStatus {
    case pending
    case executing
    case completed
    case failed
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            StepExecutionRowView(
                step: WorkflowStep(
                    stepType: WorkflowStep.StepType.summarize.rawValue,
                    prompt: "Summarize the text in 3 sentences",
                    order: 0
                ),
                index: 0,
                status: .completed,
                output: "This is a summary of the input text. It contains the main points. The content is concise.",
                duration: 1.23
            )
            
            StepExecutionRowView(
                step: WorkflowStep(
                    stepType: WorkflowStep.StepType.translate.rawValue,
                    prompt: "Translate to Spanish",
                    order: 1
                ),
                index: 1,
                status: .executing,
                output: "Este es un resumen del texto de entrada...",
                duration: 1.23
            )
            
            StepExecutionRowView(
                step: WorkflowStep(
                    stepType: WorkflowStep.StepType.analyze.rawValue,
                    prompt: "Analyze sentiment",
                    order: 2
                ),
                index: 2,
                status: .pending,
                output: "",
                duration: 1.23
            )
            
            StepExecutionRowView(
                step: WorkflowStep(
                    stepType: WorkflowStep.StepType.rewrite.rawValue,
                    prompt: "Rewrite this text",
                    order: 3
                ),
                index: 3,
                status: .failed,
                output: "",
                duration: 1.23
            )
        }
        .padding()
    }
}
