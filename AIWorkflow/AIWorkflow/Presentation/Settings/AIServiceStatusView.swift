//
//  AIServiceStatusView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 12.11.2025.
//

import SwiftUI
import FoundationModels

struct AIServiceStatusView: View {
    let isAvailable: Bool
    let availability: SystemLanguageModel.Availability
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                headerContent
                
                if case .available = availability {
                    availableView
                } else {
                    unavailableView
                }
            }
        }
    }
}

private extension AIServiceStatusView {
    var headerContent: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(L10N.Settings.AIService.status)
                    .font(.headline)
            }
            
            Spacer()
            
            statusIndicator
        }
    }
    
    var statusIndicator: some View {
        Circle()
            .fill(isAvailable ? Color.green : Color.orange)
            .frame(width: 12, height: 12)
    }
    
    var availableView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(L10N.Settings.AIService.available)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            
            Label {
                Text(L10N.Settings.AIService.Privacy.local)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } icon: {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.blue)
            }
            
            Label {
                Text(L10N.Settings.AIService.Privacy.offline)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } icon: {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(.green)
            }
        }
    }
    
    var unavailableView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(L10N.Settings.AIService.unavailable)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(L10N.Settings.AIService.requirements)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(L10N.Settings.AIService.requirementsIOS)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Text(L10N.Settings.AIService.requirementsIntelligence)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Text(L10N.Settings.AIService.requirementsDevice)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 4)
        }
    }
}

#Preview("Available") {
    AIServiceStatusView(
        isAvailable: true,
        availability: .available
    )
}

#Preview("Unavailable") {
    AIServiceStatusView(
        isAvailable: false,
        availability: .unavailable(.deviceNotEligible)
    )
}
