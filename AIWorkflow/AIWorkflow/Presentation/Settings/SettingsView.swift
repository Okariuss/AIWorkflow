//
//  SettingsView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 12.11.2025.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Environments
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - View
    var body: some View {
        NavigationStack {
            List {
                aiServiceSection
                aboutSection
                siriSection
                privacySection
                developerSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension SettingsView {
    var aiServiceSection: some View {
        Section {
            AIServiceStatusView()
        } header: {
            Text("AI Service")
        } footer: {
            Text("Powered by Apple's Foundation Models API. All processing happens on your device using on-device language model.")
        }
    }
    
    var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text(buildNumber)
                    .foregroundStyle(.secondary)
            }
            
            NavigationLink {
                AIServiceTestView()
            } label: {
                Label("Test AI Service", systemImage: "testtube.2")
            }
        }
    }
    
    var siriSection: some View {
        Section("Siri & Shortcuts") {
            NavigationLink {
                SiriSettingsView()
            } label: {
                Label("Siri Shortcuts", systemImage: "mic.fill")
            }
            
            Text("Run workflows with voice command using Siri")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    var privacySection: some View {
        Section("Privacy") {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text("100% On-Device Processing")
                        .font(.body)
                    Text("All AI runs locally on your iPhone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.blue)
            }
            
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Zero Data Collection")
                        .font(.body)
                    Text("Your data never leaves your device")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(.green)
            }
            
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Works Offline")
                        .font(.body)
                    Text("No internet connection required")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(.orange)
            }
        }
    }
    
    var developerSection: some View {
        Section("Technology") {
            HStack {
                Text("Framework")
                Spacer()
                Text("Foundation Models")
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("Architecture")
                Spacer()
                Text("On-Device LLM")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Computed Properties
private extension SettingsView {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1.0.0"
    }
}

#Preview {
    SettingsView()
}
