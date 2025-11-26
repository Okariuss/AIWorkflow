//
//  PreferencesRepositoryProtocol.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 19.11.2025.
//

import Foundation

protocol PreferencesRepositoryProtocol {
    func fetch() async throws -> UserPreferences
    func save(_ preferences: UserPreferences) async throws
    func getOrCreate() async throws -> UserPreferences
}
