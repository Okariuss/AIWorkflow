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
    @FocusState private var isTestInputFocused: Bool
    
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
                advancedOptionsSection
                testStepSection
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
    
    var advancedOptionsSection: some View {
        Section {
            Toggle("Enable Advanced Options", isOn: $viewModel.useAdvancedOptions)
                .onChange(of: viewModel.useAdvancedOptions) { _, newValue in
                    withAnimation {
                        viewModel.showAdvancedOptions = newValue
                    }
                }
            
            if viewModel.showAdvancedOptions {
                advancedOptionsContent
            }
        } header: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                Text("Advanced Options")
            }
        } footer: {
            if viewModel.useAdvancedOptions {
                Text("Temperature controls creativity (0.0=predictable, 2.0=creative). Max tokens limits response length. Sampling mode affects output determinism.")
                    .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    var advancedOptionsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Temperature")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1f", viewModel.temperature))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $viewModel.temperature, in: 0.0...2.0, step: 0.1)
                
                HStack {
                    Text("Predictable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Creative")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Max Tokens")
                        .font(.subheadline)
                    Spacer()
                    Text("\(viewModel.maxTokens)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: Binding(
                    get: { Double(viewModel.maxTokens) },
                    set: { viewModel.maxTokens = Int($0) }
                ), in: 50...4096, step: 50)
                
                HStack {
                    Text("Short")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Long")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Sampling Mode
            Picker("Sampling Mode", selection: $viewModel.samplingMode) {
                ForEach(WorkflowStep.AdvancedOptions.SamplingMode.allCases, id: \.self) { mode in
                    VStack(alignment: .leading) {
                        Text(mode.rawValue)
                        Text(mode.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(mode)
                }
            }
            .pickerStyle(.navigationLink)
            
            // Reset Button
            Button {
                withAnimation {
                    viewModel.resetAdvancedOptions()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset to Defaults")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 8)
        .transition(.opacity.combined(with: .scale))
    }
    
    var testStepSection: some View {
        Section {
            if viewModel.isTestingStep {
                HStack {
                    ProgressView()
                    Text("Testing step...")
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $viewModel.testInput)
                        .frame(minHeight: 80)
                        .focused($isTestInputFocused)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.quaternary, lineWidth: 1)
                        )
                    
                    if !viewModel.testOutput.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Output:", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            
                            Text(viewModel.testOutput)
                                .font(.body)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.quaternary.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .textSelection(.enabled)
                        }
                    }
                    
                    if let error = viewModel.testError {
                        Label(error, systemImage: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                    HStack {
                        if !viewModel.testOutput.isEmpty || viewModel.testError != nil {
                            Button("Clear") {
                                viewModel.clearTest()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Spacer()
                        
                        Button {
                            Task {
                                await viewModel.testStep()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Test Step")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.testInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        } header: {
            HStack {
                Image(systemName: "flask")
                Text("Test Step")
            }
        } footer: {
            Text("Test your step configuration with sample input before saving.")
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

#Preview("New Step") {
    StepConfigurationView(stepOrder: 0) { step in
        print("Saved step: \(step.stepType)")
    }
}

#Preview("Edit Step with Advanced Options") {
    let step = WorkflowStep(
        stepType: WorkflowStep.StepType.summarize.rawValue,
        prompt: "Summarize this text in 3 sentences",
        order: 0
    )
    
    var options = WorkflowStep.AdvancedOptions.default
    options.useAdvancedOptions = true
    options.temperature = 0.8
    options.maxTokens = 200
    options.samplingMode = .random
    step.updateAdvancedOptions(options)
    
    return StepConfigurationView(
        existingStep: step,
        stepOrder: 0
    ) { step in
        print("Updated step: \(step.stepType)")
    }
}
