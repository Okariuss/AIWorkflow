//
//  WorkflowRowView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct WorkflowRowView: View {
    let workflow: Workflow
    let onToggleFavorite: () -> Void
    
    @State private var showingExecutionSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            headerNameFavorite
            
            if !workflow.workflowDescription.isEmpty {
                descriptionText
            }
            
            footerView
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showingExecutionSheet = true
            } label: {
                Label("Run", systemImage: "play.fill")
            }
            .tint(.green)
        }
        .sheet(isPresented: $showingExecutionSheet) {
            NavigationStack {
                WorkflowExecutionView(
                    viewModel: DependencyContainer.shared.makeWorkflowExecutionViewModel(
                        workflow: workflow
                    )
                )
            }
        }
    }
}

// MARK: - UI Components
private extension WorkflowRowView {
    var headerNameFavorite: some View {
        HStack {
            Text(workflow.name)
                .font(.headline)
                .lineLimit(1)
            Spacer()
            Button(action: onToggleFavorite) {
                Image(systemName: workflow.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(workflow.isFavorite ? .yellow : .gray)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    var descriptionText: some View {
        Text(workflow.workflowDescription)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(2)
    }
    
    var footerView: some View {
        HStack {
            Label("\(workflow.stepCount) steps", systemImage: "list.bullet")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(workflow.modifiedAt.formatted(.relative(presentation: .named)))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview("Workflow Row") {
    List {
        WorkflowRowView(
            workflow: {
                let workflow = Workflow(
                    name: "Summarize & Translate",
                    workflowDescription: "Summarize text and translate to Spanish"
                )
                workflow.steps = [
                    WorkflowStep(stepType: "summarize", prompt: "Summarize", order: 0),
                    WorkflowStep(stepType: "translate", prompt: "Translate", order: 1)
                ]
                return workflow
            }(),
            onToggleFavorite: {}
        )
        
        WorkflowRowView(
            workflow: {
                let workflow = Workflow(
                    name: "Extract Key Points",
                    workflowDescription: ""
                )
                workflow.isFavorite = true
                workflow.steps = [
                    WorkflowStep(stepType: "extract", prompt: "Extract", order: 0)
                ]
                return workflow
            }(),
            onToggleFavorite: {}
        )
    }
}
