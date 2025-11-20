//
//  WidgetService.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 20.11.2025.
//

import Foundation
import WidgetKit

final class WidgetService {
    // MARK: - Dependencies
    private let workflowRepository: WorkflowRepositoryProtocol
    private let preferencesRepository: PreferencesRepositoryProtocol
    
    // MARK: - Init
    init(
        workflowRepository: WorkflowRepositoryProtocol,
        preferencesRepository: PreferencesRepositoryProtocol
    ) {
        self.workflowRepository = workflowRepository
        self.preferencesRepository = preferencesRepository
    }
}

// MARK: - Protocol Integration
extension WidgetService: WidgetServiceProtocol {
    func refreshWidgets() async {
        do {
            let prefs = try await preferencesRepository.getOrCreate()
            let allWorkflows = try await workflowRepository.fetchAll()
            
            let selectedWorkflows = allWorkflows.filter { workflow in
                prefs.widgetSelections.contains(workflow.id)
            }
            
            let workflowToMap = selectedWorkflows.isEmpty ? Array(allWorkflows.prefix(4)) : selectedWorkflows
            
            let widgetData = workflowToMap.map { workflow in
                WorkflowWidgetData(
                    id: workflow.id,
                    name: workflow.name,
                    stepCount: workflow.stepCount,
                    isFavorite: workflow.isFavorite,
                    isSelected: prefs.widgetSelections.contains(workflow.id)
                )
            }
            
            let defaults = UserDefaults(suiteName: "group.com.okarius.AIWorkflow")
            if let encoded = try? JSONEncoder().encode(widgetData) {
                defaults?.set(encoded, forKey: "workflows")
                defaults?.synchronize()
            }
            
            WidgetCenter.shared.reloadAllTimelines()
            
            print("✅ WidgetService: Widgets refreshed with \(widgetData.count) items.")
        } catch {
            print("❌ WidgetService Error: \(error.localizedDescription)")
        }
    }
}
