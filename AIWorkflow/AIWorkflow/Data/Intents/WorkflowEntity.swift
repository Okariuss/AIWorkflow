//
//  WorkflowEntity.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 16.11.2025.
//

import AppIntents

struct WorkflowEntity: AppEntity {
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Workflow")
    
    static var defaultQuery = WorkflowEntityQuery()
    
    // MARK: - Properties
    
    var id: UUID
    var displayString: String
    var workflowName: String
    var stepCount: Int
    
    // MARK: - Display Representation
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(workflowName)",
            subtitle: L10N.WorkflowEntity.steps(stepCount)
        )
    }
}


struct WorkflowEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [WorkflowEntity] {
        let container = DependencyContainer.shared
        let allWorkflows = try await container.workflowRepository.fetchAll()
        
        return allWorkflows
            .filter { identifiers.contains($0.id) }
            .map { workflow in
                WorkflowEntity(
                    id: workflow.id,
                    displayString: workflow.name,
                    workflowName: workflow.name,
                    stepCount: workflow.stepCount
                )
            }
    }
    
    @MainActor
    func suggestedEntities() async throws -> [WorkflowEntity] {
        let container = DependencyContainer.shared
        let allWorkflows = try await container.workflowRepository.fetchAll()
        
        // Return up to 4 most recent workflows
        return allWorkflows
            .prefix(4)
            .map { workflow in
                WorkflowEntity(
                    id: workflow.id,
                    displayString: workflow.name,
                    workflowName: workflow.name,
                    stepCount: workflow.stepCount
                )
            }
    }
    
    @MainActor
    func defaultResult() async -> WorkflowEntity? {
        let container = DependencyContainer.shared
        let allWorkflows = try? await container.workflowRepository.fetchAll()
        
        guard let firstWorkflow = allWorkflows?.first else {
            return nil
        }
        
        return WorkflowEntity(
            id: firstWorkflow.id,
            displayString: firstWorkflow.name,
            workflowName: firstWorkflow.name,
            stepCount: firstWorkflow.stepCount
        )
    }
}
