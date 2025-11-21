//
//  WorkflowCreationView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct WorkflowCreationView: View {
    
    // MARK: - Environments
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    @State private var viewModel: WorkflowCreationViewModel
    @State private var showingStepConfiguration = false
    @State private var editingStepIndex: Int?
    
    // MARK: - Focus State
    @FocusState private var isNameFocused: Bool
    
    // MARK: - Init
    init(viewModel: WorkflowCreationViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                workflowInfoSection
                stepsCount
            }
            .navigationTitle(viewModel.getExistingWorkflow == nil ? "New Workflow" : "Edit Workflow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingStepConfiguration) {
                stepConfigurationSheet
            }
            .alert("Invalid Workflow", isPresented: .constant(viewModel.validationError != nil)) {
                Button("OK") {
                    viewModel.clearValidationError()
                }
            } message: {
                if let error = viewModel.validationError {
                    Text(error)
                }
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
            .overlay {
                if viewModel.isLoading {
                    LoadingView(message: "Saving workflow...")
                }
            }
        }
    }
}

// MARK: - Subviews
private extension WorkflowCreationView {
    var workflowInfoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Workflow Name", text: $viewModel.name)
                    .focused($isNameFocused)
                
                if !viewModel.name.isEmpty {
                    HStack {
                        Text("\(viewModel.name.count) characters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        if viewModel.name.count < 3 {
                            Text("At least 3 characters required")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            
            TextField("Description (optional)", text: $viewModel.workflowDescription, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Workflow Info")
        } footer: {
            Text("Give your workflow a descriptive name and optional description")
                .font(.caption)
        }
    }
    
    var stepsCount: some View {
        Section {
            if viewModel.steps.isEmpty {
                ContentUnavailableView("No steps yet", systemImage: "square.stack.3d.up.slash", description: Text("Add at least one step to your workflow"))
            } else {
                ForEach(Array(viewModel.steps.enumerated()), id: \.element.id) { index, step in
                    StepRowView(step: step, index: index)
                        .contentShape(.rect)
                        .onTapGesture {
                            editStep(at: index)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            deleteButton(at: index)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            duplicateButton(at: index)
                        }
                }
                .onMove { source, destination in
                    if let sourceIndex = source.first {
                        viewModel.moveStep(from: sourceIndex, to: destination)
                    }
                }
            }
            
            Button {
                showingStepConfiguration = true
                editingStepIndex = nil
            } label: {
                Label("Add Step", systemImage: "plus.circle.fill")
                    .foregroundStyle(.blue)
            }
        } header: {
            HStack {
                Text("Steps")
                Spacer()
                if !viewModel.steps.isEmpty {
                    Text("\(viewModel.steps.count) \(viewModel.steps.count == 1 ? "step" : "steps")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } footer: {
            Text("Steps will be executed in order. Drag to reorder.")
                .font(.caption)
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                saveWorkflow()
            }
            .disabled(!viewModel.isValid || viewModel.isLoading)
            .fontWeight(.semibold)
        }
        
        if !viewModel.steps.isEmpty {
            ToolbarItem(placement: .status) {
                Text("\(viewModel.steps.count) \(viewModel.steps.count == 1 ? "step" : "steps")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    var stepConfigurationSheet: some View {
        if let index = editingStepIndex {
            StepConfigurationView(
                existingStep: viewModel.steps[index],
                stepOrder: index)
            { updatedStep in
                viewModel.updateStep(updatedStep, at: index)
            }
        } else {
            StepConfigurationView(
                stepOrder: viewModel.steps.count
            ) { newStep in
                viewModel.addStep(newStep)
            }
        }
    }
}


// MARK: Private Methods
private extension WorkflowCreationView {
    func editStep(at index: Int) {
        editingStepIndex = index
        showingStepConfiguration = true
    }
    
    func deleteButton(at index: Int) -> some View {
        Button(role: .destructive) {
            HapticManager.shared.impact(.medium)
            withAnimation {
                viewModel.deleteStep(at: index)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    func duplicateButton(at index: Int) -> some View {
        Button {
            HapticManager.shared.impact(.medium)
            withAnimation {
                viewModel.duplicateStep(at: index)
            }
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        .tint(.blue)
    }
    
    func saveWorkflow() {
        Task {
            let success = await viewModel.saveWorkflow()
            if success {
                HapticManager.shared.notification(.success)
                dismiss()
            } else {
                HapticManager.shared.notification(.error)
            }
        }
    }
}

#Preview("New Workflow") {
    let repository = DependencyContainer.shared.workflowRepository
    let viewModel = WorkflowCreationViewModel(repository: repository)
    
    return WorkflowCreationView(viewModel: viewModel)
}

#Preview("With Steps") {
    let repository = DependencyContainer.shared.workflowRepository
    let viewModel = WorkflowCreationViewModel(repository: repository)
    
    // Add sample steps
    let step1 = WorkflowStep(stepType: "summarize", prompt: "Summarize this text", order: 0)
    let step2 = WorkflowStep(stepType: "translate", prompt: "Translate to Spanish", order: 1)
    viewModel.addStep(step1)
    viewModel.addStep(step2)
    viewModel.name = "Test Workflow"
    
    return WorkflowCreationView(viewModel: viewModel)
}
