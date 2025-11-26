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
    @State private var stepToEdit: StepEditMode?
    
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
            .navigationTitle(viewModel.getExistingWorkflow == nil ? L10N.WorkflowCreation.titleNew : L10N.WorkflowCreation.titleEdit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(item: $stepToEdit) { editMode in
                stepConfigurationSheet(for: editMode)
            }
            .alert(L10N.Error.invalidWorkflow, isPresented: .constant(viewModel.validationError != nil)) {
                Button(L10N.Common.ok) {
                    viewModel.clearValidationError()
                }
            } message: {
                if let error = viewModel.validationError {
                    Text(error)
                }
            }
            .alert(L10N.Common.error, isPresented: .constant(viewModel.errorMessage != nil)) {
                Button(L10N.Common.ok) {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingView(message: L10N.Common.saving)
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
                TextField(L10N.WorkflowCreation.name, text: $viewModel.name)
                    .focused($isNameFocused)
                
                if !viewModel.name.isEmpty {
                    HStack {
                        Text(L10N.Execution.inputCharacters(viewModel.name.count))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        if viewModel.name.count < 3 {
                            Text(L10N.WorkflowCreation.Validation.nameShort)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            
            TextField(L10N.WorkflowCreation.description, text: $viewModel.workflowDescription, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text(L10N.WorkflowCreation.workflowInfo)
        } footer: {
            Text(L10N.WorkflowCreation.infoFooter)
                .font(.caption)
        }
    }
    
    var stepsCount: some View {
        Section {
            if viewModel.steps.isEmpty {
                ContentUnavailableView(L10N.WorkflowCreation.stepsEmpty, systemImage: "square.stack.3d.up.slash", description: Text(L10N.WorkflowCreation.Validation.stepsRequired))
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
                stepToEdit = .new
            } label: {
                Label(L10N.WorkflowCreation.stepsAdd, systemImage: "plus.circle.fill")
                    .foregroundStyle(.blue)
            }
        } header: {
            HStack {
                Text(L10N.WorkflowCreation.stepsTitle)
                Spacer()
                if !viewModel.steps.isEmpty {
                    Text(L10N.WorkflowCreation.stepsCount(viewModel.steps.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } footer: {
            Text(L10N.WorkflowCreation.stepsFooter)
                .font(.caption)
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(L10N.Common.cancel) {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button(L10N.Common.save) {
                saveWorkflow()
            }
            .disabled(!viewModel.isValid || viewModel.isLoading)
            .fontWeight(.semibold)
        }
        
        if !viewModel.steps.isEmpty {
            ToolbarItem(placement: .status) {
                Text(L10N.WorkflowCreation.stepsCount(viewModel.steps.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    func stepConfigurationSheet(for editMode: StepEditMode) -> some View {
        switch editMode {
        case .new:
            StepConfigurationView(
                existingStep: nil,
                stepOrder: viewModel.steps.count
            ) { step in
                viewModel.addStep(step)
                stepToEdit = nil
            }
        case .edit(let index, let step):
            StepConfigurationView(
                existingStep: step,
                stepOrder: index
            ) { updatedStep in
                viewModel.updateStep(updatedStep, at: index)
                stepToEdit = nil
            }
        }
    }
}


// MARK: Private Methods
private extension WorkflowCreationView {
    func editStep(at index: Int) {
        guard viewModel.steps.indices.contains(index) else { return }
        let step = viewModel.steps[index]
        stepToEdit = .edit(index: index, step: step)
    }
    
    func deleteButton(at index: Int) -> some View {
        Button(role: .destructive) {
            HapticManager.shared.impact(.medium)
            withAnimation {
                viewModel.deleteStep(at: index)
            }
        } label: {
            Label(L10N.Common.delete, systemImage: "trash")
        }
    }
    
    func duplicateButton(at index: Int) -> some View {
        Button {
            HapticManager.shared.impact(.medium)
            withAnimation {
                viewModel.duplicateStep(at: index)
            }
        } label: {
            Label(L10N.WorkflowDetail.Actions.duplicate, systemImage: "doc.on.doc")
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

// MARK: - Step Edit Mode
private enum StepEditMode: Identifiable {
    case new
    case edit(index: Int, step: WorkflowStep)
    
    var id: String {
        switch self {
        case .new:
            return "new"
        case .edit(let index, _):
            return "edit_\(index)"
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
