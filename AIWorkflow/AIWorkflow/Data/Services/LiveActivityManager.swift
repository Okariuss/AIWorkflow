//
//  LiveActivityManager.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import ActivityKit
import Foundation

final class LiveActivityManager {
    // MARK: - Singleton
    static let shared = LiveActivityManager()
    
    // MARK: - Properties
    private var currentActivity: Activity<WorkflowActivityAttributes>?
    
    // MARK: Init
    private init() { }
}

// MARK: Public Methods
extension LiveActivityManager {
    func areActivitiesEnabled() -> Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    func startActivity(
        workflowName: String,
        workflowId: UUID,
        totalSteps: Int
    ) async throws {
        await endActivity()
        
        let attributes = WorkflowActivityAttributes(
            workflowName: workflowName,
            workflowID: workflowId.uuidString,
            totalSteps: totalSteps,
            startTime: Date()
        )
        
        let initialState = WorkflowActivityAttributes.ContentState(
            currentStepIndex: 0,
            currentStepName: "Starting...",
            totalSteps: totalSteps,
            currentOutput: "",
            status: .running,
            progress: 0.0,
            elapsedTime: 0
        )
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled")
            return
        }
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            
            currentActivity = activity
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
        }
    }
    
    func updateActivity(
        currentStepIndex: Int,
        currentStepName: String,
        currentOutput: String,
        progress: Double,
        elapsedTime: TimeInterval
    ) async {
        guard let activity = currentActivity else {
            print("⚠️ No active Live Activity to update")
            return
        }
        
        let state = WorkflowActivityAttributes.ContentState(
            currentStepIndex: currentStepIndex,
            currentStepName: currentStepName,
            totalSteps: activity.attributes.totalSteps,
            currentOutput: currentOutput,
            status: .running,
            progress: progress,
            elapsedTime: elapsedTime
        )
        
        await activity.update(.init(state: state, staleDate: nil))
        print("🔄 Live Activity updated: Step \(currentStepIndex + 1)")
    }
    
    func endActivity(
        finalOutput: String = "",
        status: ActivityExecutionStatus = .completed,
        elapsedTime: TimeInterval = 0
    ) async {
        guard let activity = currentActivity else { return }
        
        
        let finalState = WorkflowActivityAttributes.ContentState(
            currentStepIndex: activity.attributes.totalSteps - 1,
            currentStepName: status.rawValue,
            totalSteps: activity.attributes.totalSteps,
            currentOutput: finalOutput,
            status: status,
            progress: 1.0,
            elapsedTime: elapsedTime
        )
        
        await activity.end(
            .init(state: finalState, staleDate: nil),
            dismissalPolicy: .after(.now + 3)
        )
        
        print("🏁 Live Activity ended: \(status.rawValue)")
        currentActivity = nil
    }
    
    func cancelActivity() async {
        await endActivity(status: .cancelled)
    }
}
