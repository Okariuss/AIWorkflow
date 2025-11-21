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
    
    // MARK: - State
    @State private var viewModel: SettingsViewModel
    
    // MARK: - Init
    init() {
        let container = DependencyContainer.shared
        self.viewModel = SettingsViewModel(
            repository: container.preferencesRepository,
            workflowRepository: container.workflowRepository,
            widgetService: container.widgetService
        )
    }
    
    // MARK: - View
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: "Loading preferences...")
                } else {
                    settingsList
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadPreferences()
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
        }
    }
}

// MARK: - Subviews
private extension SettingsView {
    var settingsList: some View {
        List {
            aiServiceSection
            preferencesSection
            widgetPreferencesSection
            siriSection
            privacySection
            aboutSection
            developerSection
        }
    }
    
    var aiServiceSection: some View {
        Section {
            AIServiceStatusView(
                isAvailable: viewModel.isAIAvailable,
                availability: viewModel.aiAvailability
            )
        } header: {
            Text("AI Service")
        } footer: {
            Text("Powered by Apple's Foundation Models API. All processing happens on your device using on-device language model.")
        }
    }
    
    var preferencesSection: some View {
        Section("Preferences") {
            Picker("Theme", selection: Binding(
                get: { viewModel.currentTheme },
                set: { newValue in
                    Task {
                        await viewModel.updateTheme(newValue)
                    }
                }
            )) {
                ForEach(UserPreferences.ThemePreference.allCases, id: \.self) { theme in
                    HStack {
                        Text(theme.rawValue)
                        Spacer()
                        Image(systemName: iconForTheme(theme))
                            .foregroundStyle(.secondary)
                    }
                    .tag(theme)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }
    
    var widgetPreferencesSection: some View {
        Section {
            NavigationLink {
                WidgetPreferencesView(viewModel: viewModel)
            } label: {
                HStack {
                    Label("Widget Preferences", systemImage: "rectangle.grid.2x2")
                    Spacer()
                    if !viewModel.widgetSelections.isEmpty {
                        Text("\(viewModel.widgetSelections.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Text("Configure which workflows appear in your home screen widget")
                .font(.caption)
                .foregroundStyle(.secondary)
        } header: {
            Text("Widgets")
        }
    }
    
    var siriSection: some View {
        Section("Siri & Shortcuts") {
            NavigationLink {
                SiriSettingsView()
            } label: {
                Label("Manage Shortcuts", systemImage: "list.bullet")
            }
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

// MARK: - Helpers
private extension SettingsView {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    func iconForTheme(_ theme: UserPreferences.ThemePreference) -> String {
        switch theme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

#Preview {
    SettingsView()
}
