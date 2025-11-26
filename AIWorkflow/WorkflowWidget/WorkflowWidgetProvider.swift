//
//  WorkflowWidgetProvider.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 17.11.2025.
//

import WidgetKit
import SwiftUI

struct WorkflowWidgetProvider {
    typealias Entry = WorkflowWidgetEntry
    
    
}

// MARK: - TimelineProvider
extension WorkflowWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WorkflowWidgetEntry {
        WorkflowWidgetEntry(
            date: Date(),
            workflows: [
                WorkflowWidgetData(
                    id: UUID(),
                    name: "Summarize & Translate",
                    stepCount: 3,
                    isFavorite: true,
                    isSelected: false
                ),
                
                WorkflowWidgetData(
                    id: UUID(),
                    name: "Quick Analysis",
                    stepCount: 2,
                    isFavorite: false,
                    isSelected: true
                )
            ]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WorkflowWidgetEntry) -> Void) {
        let entry = WorkflowWidgetEntry(
            date: Date(),
            workflows: loadWorkflows()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkflowWidgetEntry>) -> Void) {
        let currentDate = Date()
        
        let entry = WorkflowWidgetEntry(
            date: currentDate,
            workflows: loadWorkflows()
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

// MARK: - Private Methods
private extension WorkflowWidgetProvider {
    func loadWorkflows() -> [WorkflowWidgetData] {
        let defaults = UserDefaults(suiteName: "group.com.okarius.AIWorkflow")
        
        guard let data = defaults?.data(forKey: "workflows"),
              let workflows = try? JSONDecoder().decode([WorkflowWidgetData].self, from: data) else {
            return []
        }
        
        let selectedWorkflows = workflows.filter { $0.isSelected }
        
        if !selectedWorkflows.isEmpty {
            return Array(selectedWorkflows.prefix(4))
        }
        
        return Array(workflows.prefix(4))
    }
}
