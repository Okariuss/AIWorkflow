//
//  FoundationModelsService.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 12.11.2025.
//

import Foundation
import FoundationModels

final class FoundationModelsService {
    
    // MARK: - Singleton
    static let shared = FoundationModelsService()
    
    // MARK: - Properties
    private let model = SystemLanguageModel.default
    
    // MARK: Init
    private init() { }
}

// MARK: - AI Service
extension FoundationModelsService: AIServiceProtocol {
    func execute(prompt: String) async throws -> String {
        guard await isAvailable() else {
            throw AIServiceError.modelNotAvailable
        }
        
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.invalidResponse
        }
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            
            return response.content
        } catch {
            throw AIServiceError.executionFailed(error.localizedDescription)
        }
    }
    
    func executeWithOptions(
        prompt: String,
        temperature: Double = 0.7,
        maxTokens: Int = 500,
        samplingMode: WorkflowStep.AdvancedOptions.SamplingMode = .random
    ) async throws -> String {
        guard await isAvailable() else {
            throw AIServiceError.modelNotAvailable
        }
        
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.invalidResponse
        }
        
        // Create GenerationOptions
        let sampling: GenerationOptions.SamplingMode
        switch samplingMode {
        case .greedy:
            sampling = .greedy
        case .random:
            sampling = .random(top: 40)
        }

        let options = GenerationOptions(
            sampling: sampling,
            temperature: temperature,
            maximumResponseTokens: maxTokens
        )
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt, options: options)
            
            return response.content
        } catch {
            throw AIServiceError.executionFailed(error.localizedDescription)
        }
    }
    
    func executeStreaming(prompt: String) async throws -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard await isAvailable() else {
                        continuation.finish(throwing: AIServiceError.modelNotAvailable)
                        return
                    }
                    guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        continuation.finish(throwing: AIServiceError.invalidResponse)
                        return
                    }
                    
                    let session = LanguageModelSession()
                    
                    let responseStream = session.streamResponse(to: prompt)
                    
                    for try await partialResponse in responseStream {
                        continuation.yield(partialResponse.content)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: AIServiceError.executionFailed(error.localizedDescription))
                }
            }
        }
    }
    
    func executeStreamingWithOptions(
        prompt: String,
        temperature: Double = 0.7,
        maxTokens: Int = 500,
        samplingMode: WorkflowStep.AdvancedOptions.SamplingMode = .random
    ) async throws -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard await isAvailable() else {
                        continuation.finish(throwing: AIServiceError.modelNotAvailable)
                        return
                    }
                    
                    // Create GenerationOptions
                    let sampling: GenerationOptions.SamplingMode
                    switch samplingMode {
                    case .greedy:
                        sampling = .greedy
                    case .random:
                        sampling = .random(top: 40)
                    }
                    
                    let options = GenerationOptions(
                        sampling: sampling,
                        temperature: temperature,
                        maximumResponseTokens: maxTokens
                    )
                    
                    let session = LanguageModelSession()
                    let responseStream = session.streamResponse(to: prompt, options: options)
                    
                    for try await partialResponse in responseStream {
                        continuation.yield(partialResponse.content)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: AIServiceError.executionFailed(error.localizedDescription))
                }
            }
        }
    }
    
    func isAvailable() async -> Bool {
        model.isAvailable
    }
}

// MARK: - Public Methods
extension FoundationModelsService {
    
    func getModel() -> SystemLanguageModel {
        model
    }
    
    func availabilityDetails() -> SystemLanguageModel.Availability {
        model.availability
    }
    
    func executeWithInstructions(
        instructions: String,
        prompt: String
    ) async throws -> String {
        guard await isAvailable() else {
            throw AIServiceError.modelNotAvailable
        }
        
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: prompt)
        
        return response.content
    }
    
    func executeStructured<T: Generable>(
        prompt: String,
        generating type: T.Type
    ) async throws -> T {
        guard await isAvailable() else {
            throw AIServiceError.modelNotAvailable
        }
        
        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt, generating: type)
        
        return response.content
    }
}
