//
//  WorkflowExecutionView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 14.11.2025.
//

import SwiftUI

struct WorkflowExecutionView: View {
    // MARK: - Environments
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    @FocusState private var isInputFocused: Bool
    @State private var viewModel: WorkflowExecutionViewModel
    
    // MARK: - Init
    init(viewModel: WorkflowExecutionViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - View
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    if !viewModel.isExecuting && viewModel.executionResult == nil {
                        inputSection
                    }
                    
                    if LiveActivityManager.shared.areActivitiesEnabled() {
                        liveActivityIndicator
                    }
                    
                    if !viewModel.isExecuting || !viewModel.completedSteps.isEmpty {
                        executionSection
                    }
                    
                    if let result = viewModel.executionResult {
                        resultsSection(result: result)
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.workflow.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert(L10N.Execution.errorTitle, isPresented: .constant(viewModel.errorMessage != nil)) {
                Button(L10N.Common.ok) {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .onChange(of: viewModel.currentStepIndex) { _, newValue in
                withAnimation {
                    proxy.scrollTo("step-\(newValue)", anchor: .center)
                }
            }
        }
    }
}

// MARK: - Subviews
private extension WorkflowExecutionView {
    var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L10N.Execution.input, systemImage: "text.alignleft")
                .font(.headline)
            
            TextEditor(text: $viewModel.inputText)
                .frame(minHeight: 120)
                .padding(8)
                .background(.quaternary.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
                )
                .focused($isInputFocused)
            
            Text(L10N.Execution.inputCharacters(viewModel.inputText.count))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    var liveActivityIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(.blue)
            
            Text(L10N.Execution.liveActivityEnabled)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    var executionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerWithProgress
            
            if viewModel.isExecuting {
                ProgressView(value: viewModel.progress)
                    .tint(.blue)
                    .animation(.easeInOut, value: viewModel.progress)
            }
            
            stepsList
        }
        .animation(.spring(response: 0.4), value: viewModel.currentStepIndex)
    }
    
    var headerWithProgress: some View {
        HStack {
            Label(L10N.Execution.progress, systemImage: "gearshape.2")
                .font(.headline)
            
            Spacer()
            
            if viewModel.isExecuting {
                Text("\(viewModel.completedSteps.count + 1)\(viewModel.workflow.stepCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
        }
    }
    
    var stepsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.workflow.sortedSteps.enumerated()), id: \.element.id) { index, step in
                let status = getStepStatus(for: index)
                let output = getStepOutput(for: index)
                
                StepExecutionRowView(
                    step: step,
                    index: index,
                    status: status,
                    output: output,
                    duration: index < viewModel.completedSteps.count ? viewModel.completedSteps[index].duration : nil
                )
                .id("step-\(index)")
                .transition(.opacity.combined(with: .scale))
                
                if index < viewModel.workflow.sortedSteps.count - 1 {
                    Divider()
                        .padding(.leading, 44)
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
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if !viewModel.isExecuting && viewModel.executionResult == nil {
                Button(L10N.Common.cancel) {
                    dismiss()
                }
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            if viewModel.isExecuting {
                Button(L10N.Common.stop, role: .destructive) {
                    viewModel.cancel()
                }
            } else if viewModel.executionResult == nil {
                Button(L10N.Common.run) {
                    isInputFocused = false
                    Task {
                        await viewModel.execute()
                    }
                }
                .disabled(!viewModel.canExecute)
                .fontWeight(.semibold)
            } else {
                Button(L10N.Common.done) {
                    dismiss()
                }
            }
        }
    }
    
    func resultsSection(result: WorkflowExecutionResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(L10N.Execution.results, systemImage: result.status.icon)
                    .font(.headline)
                
                Spacer()
                
                statusBadge(for: result.status)
            }
            
            executionStats(for: result)
            
            finalOutput(for: result)
            
            actionButtons(for: result)
        }
    }
    
    func statusBadge(for status: ExecutionStatus) -> some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
            Text(status.title)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(colorForStatus(status))
        .clipShape(.capsule)
    }
    
    func executionStats(for result: WorkflowExecutionResult) -> some View {
        VStack(spacing: 12) {
            HStack {
                Label(L10N.Execution.Results.duration, systemImage: "clock")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.2fs", result.totalDuration))
                    .fontWeight(.medium)
            }
            
            Divider()
            
            HStack {
                Label(L10N.Execution.Results.stepsCompleted, systemImage: "checkmark.circle")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(result.stepResults.filter { $0.isSuccess }.count)\(result.stepResults.count)")
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    func finalOutput(for result: WorkflowExecutionResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(L10N.Execution.Results.output, systemImage: "doc.text")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ScrollView {
                Text(result.finalOutput)
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
    
    func actionButtons(for result: WorkflowExecutionResult) -> some View {
        HStack {
            Button {
                UIPasteboard.general.string = result.finalOutput
            } label: {
                Label(L10N.Execution.Actions.copy, systemImage: "doc.on.doc")
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            Button {
                viewModel.reset()
            } label: {
                Label(L10N.Execution.Actions.runAgain, systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Private Methods
private extension WorkflowExecutionView {
    func getStepStatus(for index: Int) -> StepStatus {
        if index < viewModel.completedSteps.count {
            let result = viewModel.completedSteps[index]
            return result.isSuccess ? .completed : .failed
        } else if index == viewModel.currentStepIndex && viewModel.isExecuting {
            return .executing
        } else {
            return .pending
        }
    }
    
    func getStepOutput(for index: Int) -> String {
        if index < viewModel.completedSteps.count {
            return viewModel.completedSteps[index].output
        } else if index == viewModel.currentStepIndex && viewModel.isExecuting {
            return viewModel.currentOutput
        } else {
            return ""
        }
    }
    
    func colorForStatus(_ status: ExecutionStatus) -> Color {
        switch status {
        case .success: .green
        case .failed: .red
        case .cancelled: .orange
        }
    }
}

#Preview {
    NavigationStack {
        WorkflowExecutionView(
            viewModel: {
                let workflow = Workflow(
                    name: "Summarize & Translate",
                    workflowDescription: "Test workflow"
                )
                
                let step1 = WorkflowStep(
                    stepType: WorkflowStep.StepType.summarize.rawValue,
                    prompt: "Summarize in 3 sentences",
                    order: 0
                )
                let step2 = WorkflowStep(
                    stepType: WorkflowStep.StepType.translate.rawValue,
                    prompt: "Translate to Spanish",
                    order: 1
                )
                
                step1.workflow = workflow
                step2.workflow = workflow
                workflow.steps = [step1, step2]
                
                let container = DependencyContainer.shared
                return WorkflowExecutionViewModel(
                    workflow: workflow,
                    executionService: container.workflowExecutionService
                )
            }()
        )
    }
}
