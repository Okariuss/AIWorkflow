//
//  WorkflowWidgetEntry.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 17.11.2025.
//

import WidgetKit
import Foundation

struct WorkflowWidgetEntry: TimelineEntry {
    let date: Date
    let workflows: [WorkflowWidgetData]
}

struct WorkflowWidgetData:  Identifiable, Codable {
    let id: UUID
    let name: String
    let stepCount: Int
    let isFavorite: Bool
    let isSelected: Bool
    
    init(id: UUID, name: String, stepCount: Int, isFavorite: Bool, isSelected: Bool) {
        self.id = id
        self.name = name
        self.stepCount = stepCount
        self.isFavorite = isFavorite
        self.isSelected = isSelected
    }
}
