//
//  Workflow.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation
import SwiftData

@Model
final class Workflow {
    var id: UUID
    var name: String
    var workflowDescription: String
    var createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \WorkflowStep.workflow)
    var steps: [WorkflowStep]
    
    init(
        id: UUID = UUID(),
        name: String,
        workflowDescription: String = "",
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        isFavorite: Bool = false,
        steps: [WorkflowStep] = []
    ) {
        self.id = id
        self.name = name
        self.workflowDescription = workflowDescription
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.isFavorite = isFavorite
        self.steps = steps
    }
}

// MARK: - Computed Properties
extension Workflow {
    
    var stepCount: Int {
        steps.count
    }
    
    var hasSteps: Bool {
        !steps.isEmpty
    }
    
    var sortedSteps: [WorkflowStep] {
        steps.sorted { $0.order < $1.order }
    }
}
