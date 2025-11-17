//
//  WidgetDataManager.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 17.11.2025.
//

import Foundation
import WidgetKit

final class WidgetDataManager {
    // MARK: - Singleton
    static let shared = WidgetDataManager()
    
    // MARK: - Properties
    private let defaults = UserDefaults(suiteName: "group.com.okarius.AIWorkflow")
    private let workflowsKey = "workflows"
    
    // MARK: - Init
    private init() { }
}

// MARK: - Public Methods
extension WidgetDataManager {
    func updateWidgetData(_ workflows: [Workflow]) {
        let widgetData = workflows.map { workflow in
            WorkflowWidgetData(
                id: workflow.id,
                name: workflow.name,
                stepCount: workflow.stepCount,
                isFavorite: workflow.isFavorite
            )
        }
        
        if let encoded = try? JSONEncoder().encode(widgetData) {
            defaults?.set(encoded, forKey: workflowsKey)
            
            reloadWidgets()
        }
    }
    
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
