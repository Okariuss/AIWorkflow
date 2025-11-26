//
//  SiriSettingsView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 16.11.2025.
//

import SwiftUI
import AppIntents

struct SiriSettingsView: View {
    
    // MARK: - State
    @State private var availableWorkflows: [Workflow] = []
    @State private var isLoading = false
    
    private let repository = DependencyContainer.shared.workflowRepository
    
    // MARK: - View
    var body: some View {
        List {
            siriShortcutsSection
            availableWorkflowsSection
            voiceCommandsSection
            howToUseSection
        }
        .navigationTitle(L10N.Siri.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadWorkflows()
        }
    }
}

// MARK: - Subviews
private extension SiriSettingsView {
    var siriShortcutsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10N.Siri.title)
                            .font(.headline)
                        
                        Text(L10N.Siri.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    var availableWorkflowsSection: some View {
        Section(L10N.Siri.available) {
            if isLoading {
                LoadingView(message: L10N.Common.loading)
            } else if availableWorkflows.isEmpty {
                Text(L10N.Siri.emptyWorkflow)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(availableWorkflows, id: \.id) { workflow in
                    WorkflowShortcutRow(workflow: workflow)
                }
            }
        }
    }
    
    var voiceCommandsSection: some View {
        Section(L10N.Siri.commands) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10N.Siri.commandsExamples)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                exampleCommand(L10N.Siri.commandsExample1)
                exampleCommand(L10N.Siri.commandsExample2)
                exampleCommand(L10N.Siri.commandsExample3)
            }
            .padding(.vertical, 4)
        }
    }
    
    var howToUseSection: some View {
        Section(L10N.Siri.howTo) {
            VStack(alignment: .leading, spacing: 12) {
                instructionStep(
                    number: 1,
                    title: L10N.Siri.HowTo.step1Title,
                    description: L10N.Siri.HowTo.step1Description
                )
                
                Divider()
                
                instructionStep(
                    number: 2,
                    title: L10N.Siri.HowTo.step2Title,
                    description: L10N.Siri.HowTo.step2Description
                )
                
                Divider()
                
                instructionStep(
                    number: 3,
                    title: L10N.Siri.HowTo.step3Title,
                    description: L10N.Siri.HowTo.step3Description
                )
            }
        }
    }
    
    func exampleCommand(_ command: String) -> some View {
        HStack {
            Image(systemName: "quote.opening")
                .font(.caption)
                .foregroundStyle(.blue)
            
            Text(command)
                .font(.caption)
                .italic()
                
            Image(systemName: "quote.closing")
                .font(.caption)
                .foregroundStyle(.blue)
        }
    }
    
    func instructionStep(
        number: Int,
        title: String,
        description: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(.blue))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Private Methods
private extension SiriSettingsView {
    func loadWorkflows() async {
        isLoading = true
        do {
            availableWorkflows = try await repository.fetchAll()
        } catch {
            print("\(L10N.Error.preferencesFailed): \(error)")
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        SiriSettingsView()
    }
}
