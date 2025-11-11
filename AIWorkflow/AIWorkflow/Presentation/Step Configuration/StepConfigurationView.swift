//
//  StepConfigurationView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct StepConfigurationView: View {
    // MARK: - Environments
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Focus States
    @FocusState private var isPromptFocused: Bool
    
    // MARK: - Properties
    @State private var viewModel: StepConfigurationViewModel
    let onSave: (WorkflowStep) -> Void
    let stepOrder: Int
    
    // MARK: - Init
    init(
        existingStep: WorkflowStep? = nil,
        stepOrder: Int,
        onSave: @escaping (WorkflowStep) -> Void
    ) {
        self.viewModel = StepConfigurationViewModel(existingStep: existingStep)
        self.stepOrder = stepOrder
        self.onSave = onSave
    }
    
    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                stepTypeSection
                promptSection
                previewSection
            }
            .navigationTitle(viewModel.getExistingStep == nil ? "Add Step" : "Edit Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("Invalid Step", isPresented: .constant(viewModel.validationError != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.validationError {
                    Text(error)
                }
            }
            .onAppear {
                isPromptFocused = true
            }
        }
    }
}

// MARK: - Subviews
private extension StepConfigurationView {
    var stepTypeSection: some View {
        Section {
            Picker("Step Type", selection: $viewModel.selectedStepType) {
                ForEach(WorkflowStep.StepType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.rawValue)
                        Spacer()
                        Image(systemName: iconForStepType(type))
                            .foregroundStyle(.secondary)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Text("Type")
        } footer: {
            if !viewModel.selectedStepType.systemPrompt.isEmpty {
                Text("System Prompt: \(viewModel.selectedStepType.systemPrompt)")
                    .font(.caption)
            }
        }
    }
    
    var promptSection: some View {
        Section {
            TextEditor(text: $viewModel.prompt)
                .frame(minHeight: 100)
                .focused($isPromptFocused)
            
            if !viewModel.prompt.isEmpty {
                HStack {
                    Text("\(viewModel.prompt.count) characters")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Clear") {
                        viewModel.prompt = ""
                    }
                    .font(.caption)
                }
            }
        } header: {
            Text("Instructions")
        } footer: {
            Text("Enter specific instructions for this step. Be as detailed as possible.")
                .font(.caption)
        }
    }
    
    @ViewBuilder
    var previewSection: some View {
        if !viewModel.prompt.isEmpty {
            Section {
                Text(viewModel.fullPrompt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                HStack {
                    Text("Full Prompt Preview")
                    Spacer()
                    Image(systemName: "eye")
                }
            }
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
                saveStep()
            }
            .disabled(!viewModel.isValid)
            .fontWeight(.semibold)
        }
    }
}

// MARK: - Actions
private extension StepConfigurationView {
    
    func saveStep() {
        guard viewModel.validate() else { return }
        
        let step = viewModel.createStep(order: stepOrder)
        onSave(step)
        dismiss()
    }
    
    func iconForStepType(_ type: WorkflowStep.StepType) -> String {
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

#Preview {
    StepConfigurationView(stepOrder: 0) { step in
        print("Saved step: \(step.stepType)")
    }
}

#Preview("Edit Mode") {
    let step = WorkflowStep(
        stepType: WorkflowStep.StepType.summarize.rawValue,
        prompt: "Summarize this text in 3 sentences",
        order: 0
    )
    
    return StepConfigurationView(
        existingStep: step,
        stepOrder: 0
    ) { step in
        print("Updated step: \(step.stepType)")
    }
}
