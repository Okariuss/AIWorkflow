//
//  UserPreferences.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 19.11.2025.
//

import Foundation
import SwiftData

@Model
final class UserPreferences {
    var id: UUID
    var defaultWorkflowId: UUID?
    var themePreference: String
    var widgetSelectionsJSON: String // JSON string array
    var createdAt: Date
    var modifiedAt: Date
    
    init(
        id: UUID = UUID(),
        defaultWorkflowId: UUID? = nil,
        themePreference: String = ThemePreference.system.rawValue,
        widgetSelectionsJSON: String = "[]",
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.defaultWorkflowId = defaultWorkflowId
        self.themePreference = themePreference
        self.widgetSelectionsJSON = widgetSelectionsJSON
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Theme Preference
extension UserPreferences {
    enum ThemePreference: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
    
    var theme: ThemePreference {
        ThemePreference(rawValue: themePreference) ?? .system
    }
    
    func setTheme(_ theme: ThemePreference) {
        self.themePreference = theme.rawValue
        self.modifiedAt = Date()
    }
}

// MARK: - Widget Selections
extension UserPreferences {
    var widgetSelections: [UUID] {
        guard let data = widgetSelectionsJSON.data(using: .utf8),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return ids
    }
    
    func setWidgetSelections(_ ids: [UUID]) {
        if let data = try? JSONEncoder().encode(ids),
           let json = String(data: data, encoding: .utf8) {
            self.widgetSelectionsJSON = json
            self.modifiedAt = Date()
        }
    }
    
    func addWidgetSelection(_ workflowId: UUID) {
        var selections = widgetSelections
        if !selections.contains(workflowId) && selections.count < 4 {
            selections.append(workflowId)
            setWidgetSelections(selections)
        }
    }
    
    func removeWidgetSelection(_ workflowId: UUID) {
        var selections = widgetSelections
        selections.removeAll { $0 == workflowId }
        setWidgetSelections(selections)
    }
}
