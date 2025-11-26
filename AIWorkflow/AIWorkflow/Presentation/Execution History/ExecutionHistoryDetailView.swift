//
//  ExecutionHistoryDetailView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import SwiftUI

struct ExecutionHistoryDetailView: View {
    
    // MARK: - Properties
    let execution: ExecutionHistory
    
    @State private var showingShareSheet = false
    
    // MARK: - View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                statusCard
                
                infoCard
                
                inputSection
                
                if !execution.stepResults.isEmpty {
                    stepResultsSection
                }
                
                outputSection
            }
            .padding()
        }
        .navigationTitle(L10N.History.Detail.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateShareText()])
        }
    }
}

// MARK: Subvies
private extension ExecutionHistoryDetailView {
    var statusCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(execution.executionStatus?.icon ?? "circle")
                    .font(.title2)
                    .foregroundStyle(statusColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(execution.status)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(execution.executedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var infoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Label(L10N.History.Detail.workflow, systemImage: "square.stack.3d.up")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(execution.workflowName)
                    .fontWeight(.medium)
            }
            
            Divider()
            
            HStack {
                Label(L10N.History.Detail.duration, systemImage: "timer")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.2f \(L10N.Common.seconds)", execution.duration))
                    .fontWeight(.medium)
            }
            
            Divider()
            
            HStack {
                Label(L10N.History.Detail.executed, systemImage: "clock")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(execution.executedAt.formatted(.relative(presentation: .named)))
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(L10N.History.Detail.input, systemImage: "text.alignleft")
                .font(.headline)
            
            ScrollView {
                Text(execution.inputText)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(maxHeight: 150)
            .background(.quaternary.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    var stepResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L10N.History.Detail.steps, systemImage: "list.bullet")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(Array(execution.stepResults.enumerated()), id: \.offset) { index, stepResult in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(.blue))
                            
                            Text(stepResult.stepName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(String(format: "%.2fs", stepResult.duration))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(stepResult.output)
                            .font(.body)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding()
                    
                    if index < execution.stepResults.count - 1 {
                        Divider()
                    }
                }
            }
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
    }
    
    var outputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(L10N.History.Detail.output, systemImage: "doc.text")
                .font(.headline)
            
            ScrollView {
                Text(execution.outputText)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(maxHeight: 200)
            .background(.quaternary.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                UIPasteboard.general.string = execution.outputText
            } label: {
                Label(L10N.Execution.Actions.copy, systemImage: "doc.on.doc")
            }
            .disabled(execution.outputText.isEmpty)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingShareSheet = true
            } label: {
                Label(L10N.Common.share, systemImage: "square.and.arrow.up")
            }
        }
    }
}

// MARK: - Helpers
private extension ExecutionHistoryDetailView {
    var statusColor: Color {
        switch execution.executionStatus {
        case .success: return .green
        case .failed: return .red
        case .cancelled: return .orange
        case .none: return .gray
        }
    }
    
    func generateShareText() -> String {
        var text = """
            \(L10N.History.Share.title)
            ========================
            
            \(L10N.History.Detail.workflow): \(execution.workflowName)
            \(L10N.Execution.Results.status): \(execution.status)
            \(L10N.History.Share.date): \(execution.executedAt.formatted(date: .long, time: .shortened))
            \(L10N.Execution.Results.duration): \(String(format: "%.2f \(L10N.Common.seconds)", execution.duration))
            
            \(L10N.History.Share.input):
            \(execution.inputText)
            
            """
        
        if !execution.stepResults.isEmpty {
            text += "\n\(L10N.History.Detail.steps.uppercased()):\n"
            for (index, step) in execution.stepResults.enumerated() {
                text += "\n\(index + 1). \(step.stepName) (\(String(format: "%.2fs", step.duration)))\n"
                text += "\(step.output)\n"
            }
        }
        
        text += """
            
            \(L10N.History.Detail.output.uppercased()):
            \(execution.outputText)
            """
        
        return text
    }
}

#Preview {
    NavigationStack {
        ExecutionHistoryDetailView(
            execution: {
                let history = ExecutionHistory(
                    workflowId: UUID(),
                    workflowName: "Summarize & Translate",
                    executedAt: Date().addingTimeInterval(-3600),
                    duration: 2.5,
                    status: ExecutionHistory.Status.success.rawValue,
                    inputText: "SwiftUI is Apple's modern framework for building user interfaces across all Apple platforms. It uses a declarative syntax that makes it easy to create beautiful and responsive apps.",
                    outputText: "SwiftUI es el framework moderno de Apple para construir interfaces de usuario en todas las plataformas. Utiliza una sintaxis declarativa que facilita la creación de aplicaciones hermosas y responsivas."
                )
                
                history.setStepResults([
                    ExecutionHistory.StepResult(
                        stepName: "Summarize",
                        output: "SwiftUI is Apple's modern UI framework. It uses declarative syntax for building apps.",
                        duration: 1.2
                    ),
                    ExecutionHistory.StepResult(
                        stepName: "Translate",
                        output: "SwiftUI es el framework moderno de Apple para construir interfaces de usuario.",
                        duration: 1.3
                    )
                ])
                
                return history
            }()
        )
    }
}
