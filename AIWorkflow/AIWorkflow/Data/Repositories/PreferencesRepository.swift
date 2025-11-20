//
//  PreferencesRepository.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 19.11.2025.
//

import Foundation
import SwiftData

final class PreferencesRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - Protocol Implementation
@MainActor
extension PreferencesRepository: PreferencesRepositoryProtocol {
    func fetch() async throws -> UserPreferences {
        let descriptor = FetchDescriptor<UserPreferences>()
        let preferences = try modelContext.fetch(descriptor)
        
        guard let first = preferences.first else {
            throw PreferencesError.notFound
        }
        
        return first
    }
    
    func save(_ preferences: UserPreferences) async throws {
        preferences.modifiedAt = Date()
        modelContext.insert(preferences)
        try modelContext.save()
    }
    
    func getOrCreate() async throws -> UserPreferences {
        do {
            return try await fetch()
        } catch {
            let newPreferences = UserPreferences()
            try await save(newPreferences)
            return newPreferences
        }
    }
}

// MARK: - Errors
enum PreferencesError: LocalizedError {
    case notFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Preferences not found"
        case .saveFailed:
            return "Failed to save preferences"
        }
    }
}
