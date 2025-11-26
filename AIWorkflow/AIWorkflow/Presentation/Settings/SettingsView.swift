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
                    LoadingView(message: L10N.Common.loading)
                } else {
                    settingsList
                }
            }
            .navigationTitle(L10N.Settings.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10N.Common.done) {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadPreferences()
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
            Text(L10N.Settings.AIService.title)
        } footer: {
            Text(L10N.Settings.AIService.description)
        }
    }
    
    var preferencesSection: some View {
        Section(L10N.Settings.Preferences.title) {
            Picker(L10N.Settings.Preferences.theme, selection: Binding(
                get: { viewModel.currentTheme },
                set: { newValue in
                    Task {
                        await viewModel.updateTheme(newValue)
                    }
                }
            )) {
                ForEach(UserPreferences.ThemePreference.allCases, id: \.self) { theme in
                    HStack {
                        Text(theme.title)
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
                    Label(L10N.Settings.Widgets.preferences, systemImage: "rectangle.grid.2x2")
                    Spacer()
                    if !viewModel.widgetSelections.isEmpty {
                        Text("\(viewModel.widgetSelections.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Text(L10N.Settings.Widgets.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        } header: {
            Text(L10N.Settings.Widgets.title)
        }
    }
    
    var siriSection: some View {
        Section(L10N.Settings.Siri.title) {
            NavigationLink {
                SiriSettingsView()
            } label: {
                Label(L10N.Settings.Siri.manage, systemImage: "list.bullet")
            }
        }
    }
    
    var privacySection: some View {
        Section(L10N.Settings.Privacy.title) {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10N.Settings.Privacy.onDeviceTitle)
                        .font(.body)
                    Text(L10N.Settings.Privacy.onDeviceDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.blue)
            }
            
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10N.Settings.Privacy.noDataTitle)
                        .font(.body)
                    Text(L10N.Settings.Privacy.noDataDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(.green)
            }
            
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10N.Settings.Privacy.offlineTitle)
                        .font(.body)
                    Text(L10N.Settings.Privacy.offlineDescription)
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
        Section(L10N.Settings.About.title) {
            HStack {
                Text(L10N.Settings.About.version)
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text(L10N.Settings.About.build)
                Spacer()
                Text(buildNumber)
                    .foregroundStyle(.secondary)
            }
            
            NavigationLink {
                AIServiceTestView()
            } label: {
                Label(L10N.Settings.About.test, systemImage: "testtube.2")
            }
        }
    }
    
    var developerSection: some View {
        Section(L10N.Settings.Technology.title) {
            HStack {
                Text(L10N.Settings.Technology.framework)
                Spacer()
                Text(L10N.Settings.Technology.frameworkValue)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text(L10N.Settings.Technology.architecture)
                Spacer()
                Text(L10N.Settings.Technology.architectureValue)
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
