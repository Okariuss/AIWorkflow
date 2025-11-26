//
//  AIServiceProtocol.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation

protocol AIServiceProtocol {
    func execute(prompt: String) async throws -> String
    func executeStreaming(prompt: String) async throws -> AsyncThrowingStream<String, Error>
    func executeWithOptions(prompt: String, temperature: Double, maxTokens: Int, samplingMode: WorkflowStep.AdvancedOptions.SamplingMode) async throws -> String
    func executeStreamingWithOptions(prompt: String, temperature: Double, maxTokens: Int, samplingMode: WorkflowStep.AdvancedOptions.SamplingMode) async throws -> AsyncThrowingStream<String, Error>
    func isAvailable() async -> Bool
}

// MARK: - AI Service Errors
enum AIServiceError: LocalizedError {
    case modelNotAvailable
    case invalidResponse
    case executionFailed(String)
    case cancelled
    
    
    var errorDescription: String? {
        switch self {
        case .modelNotAvailable: L10N.Error.aiModelUnavailable
        case .invalidResponse: L10N.Error.aiInvalidResponse
        case .executionFailed(let message): L10N.Error.aiExecutionFailed(message)
        case .cancelled: L10N.Error.aiCancelled
        }
    }
}
