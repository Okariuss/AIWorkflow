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
        .navigationTitle("Siri Shortcuts")
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
                        Text("Siri Shortcuts")
                            .font(.headline)
                        
                        Text("Run workflows with voice commands.")
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
        Section("Available Workflows") {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading workflows...")
                        .foregroundStyle(.secondary)
                }
            } else if availableWorkflows.isEmpty {
                Text("No workflows available")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(availableWorkflows, id: \.id) { workflow in
                    WorkflowShortcutRow(workflow: workflow)
                }
            }
        }
    }
    
    var voiceCommandsSection: some View {
        Section("Voice Commands") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Examples:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                exampleCommand("Run Summarize & Translate")
                exampleCommand("Execute my workflow")
                exampleCommand("Process text with [workflow name]")
            }
            .padding(.vertical, 4)
        }
    }
    
    var howToUseSection: some View {
        Section("How To Use") {
            VStack(alignment: .leading, spacing: 12) {
                instructionStep(
                    number: 1,
                    title: "Say 'Hey Siri'",
                    description: "Activate Siri on your device"
                )
                
                Divider()
                
                instructionStep(
                    number: 2,
                    title: "Say the command",
                    description: "Use one of the voice command above"
                )
                
                Divider()
                
                instructionStep(
                    number: 3,
                    title: "Provide input",
                    description: "Siri will ask for the text to process"
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
            print("Failed to load workflows: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        SiriSettingsView()
    }
}
