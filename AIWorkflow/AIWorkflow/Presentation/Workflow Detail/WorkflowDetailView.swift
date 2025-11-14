//
//  WorkflowDetailView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct WorkflowDetailView: View {
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    @State private var viewModel: WorkflowDetailViewModel
    @State private var showingEditSheet = false
    @State private var showingDuplicateSuccess = false
    @State private var showingExecutionSheet = false
    @State private var duplicatedWorkflow: Workflow?
    @State private var navigateToDuplicatedWorkflow = false
    
    // MARK: - Init
    init(viewModel: WorkflowDetailViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !viewModel.workflow.workflowDescription.isEmpty {
                    descriptionSection
                }
                
                WorkflowInfoCardView(
                    workflow: viewModel.workflow,
                    createdDate: viewModel.createdDateFormatted,
                    modifiedDate: viewModel.modifiedDateRelative
                )
                
                if viewModel.workflow.hasSteps {
                    stepsSection
                } else {
                    EmptyStateView(
                        message: "No steps in this workflow",
                        systemImage: "square.stack.3d.up.slash",
                        actionTitle: "Add Steps"
                    ) {
                        showingEditSheet = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.workflow.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingEditSheet) {
            WorkflowCreationView(viewModel: DependencyContainer.shared.makeWorkflowCreationViewModel(existingWorkflow: viewModel.workflow))
        }
        .sheet(isPresented: $showingExecutionSheet) {
            NavigationStack {
                WorkflowExecutionView(
                    viewModel: DependencyContainer.shared.makeWorkflowExecutionViewModel(
                        workflow: viewModel.workflow
                    )
                )
            }
        }
        .alert("Delete Workflow?", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteWorkflow()
                }
            }
        } message: {
            Text("This action cannot be undone. The workflow and all its steps will be permanently deleted.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("Workflow Duplicated", isPresented: $showingDuplicateSuccess) {
            Button("OK") {}
            if let duplicated = duplicatedWorkflow {
                Button("View Copy") {
                    duplicatedWorkflow = duplicated
                    navigateToDuplicatedWorkflow = true
                }
            }
        } message: {
            Text("A copy of this workflow has been created.")
        }
        .navigationDestination(isPresented: $navigateToDuplicatedWorkflow) {
            if let duplicated = duplicatedWorkflow {
                WorkflowDetailView(
                    viewModel: DependencyContainer.shared.makeWorkflowDetailViewModel(workflow: duplicated)
                )
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .onChange(of: viewModel.wasDeleted) { _, wasDeleted in
            if wasDeleted {
                dismiss()
            }
        }
    }
}

// MARK: - Subviews
private extension WorkflowDetailView {
    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Description", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.workflow.workflowDescription)
                .font(.body)
        }
    }
    
    var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Steps", systemImage: "list.bullet")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.workflow.stepCount) \(viewModel.workflow.stepCount == 1 ? "step" : "steps")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(Array(viewModel.workflow.sortedSteps.enumerated()), id: \.element.id) { index, step in
                    StepDetailRowView(step: step, index: index)
                    
                    if index < viewModel.workflow.sortedSteps.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    showingExecutionSheet = true
                } label: {
                    Label("Run Workflow", systemImage: "play.fill")
                }
                .disabled(!viewModel.canRun)
                
                Divider()
                
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button {
                    Task {
                        await viewModel.toggleFavorite()
                    }
                } label: {
                    Label(
                        viewModel.workflow.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                        systemImage: viewModel.workflow.isFavorite ? "star.slash" : "star.fill"
                    )
                }
                
                Button {
                    Task {
                        if let duplicated = await viewModel.duplicateWorkflow() {
                            duplicatedWorkflow = duplicated
                            showingDuplicateSuccess = true
                        }
                    }
                } label: {
                    Label("Duplicate", systemImage: "doc.on.doc")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    viewModel.showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await viewModel.toggleFavorite()
                }
            } label: {
                Image(systemName: viewModel.workflow.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(viewModel.workflow.isFavorite ? .yellow : .gray)
            }
        }
    }
}

#Preview("With Steps") {
    NavigationStack {
        WorkflowDetailView(
            viewModel: {
                let workflow = Workflow(
                    name: "Summarize & Translate",
                    workflowDescription: "Summarize any text and translate it to Spanish for easy understanding."
                )
                workflow.isFavorite = true
                
                let step1 = WorkflowStep(
                    stepType: WorkflowStep.StepType.summarize.rawValue,
                    prompt: "Summarize the following text in exactly 3 sentences, focusing on the main points and key takeaways.",
                    order: 0
                )
                let step2 = WorkflowStep(
                    stepType: WorkflowStep.StepType.translate.rawValue,
                    prompt: "Translate the summary to Spanish, maintaining the tone and meaning.",
                    order: 1
                )
                
                step1.workflow = workflow
                step2.workflow = workflow
                workflow.steps = [step1, step2]
                
                let repository = DependencyContainer.shared.workflowRepository
                return WorkflowDetailViewModel(workflow: workflow, repository: repository)
            }()
        )
    }
}

#Preview("Empty Workflow") {
    NavigationStack {
        WorkflowDetailView(
            viewModel: {
                let workflow = Workflow(
                    name: "Empty Workflow",
                    workflowDescription: "This workflow has no steps yet."
                )
                
                let repository = DependencyContainer.shared.workflowRepository
                return WorkflowDetailViewModel(workflow: workflow, repository: repository)
            }()
        )
    }
}

#Preview("No Description") {
    NavigationStack {
        WorkflowDetailView(
            viewModel: {
                let workflow = Workflow(
                    name: "Simple Workflow",
                    workflowDescription: ""
                )
                
                let step = WorkflowStep(
                    stepType: WorkflowStep.StepType.summarize.rawValue,
                    prompt: "Summarize this text",
                    order: 0
                )
                step.workflow = workflow
                workflow.steps = [step]
                
                let repository = DependencyContainer.shared.workflowRepository
                return WorkflowDetailViewModel(workflow: workflow, repository: repository)
            }()
        )
    }
}
