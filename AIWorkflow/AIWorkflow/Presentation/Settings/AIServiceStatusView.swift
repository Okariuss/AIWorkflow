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
                Text("On-Device AI")
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
                Text("AI processing is available on this device")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            
            Label {
                Text("All workflows run locally with complete privacy")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } icon: {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.blue)
            }
            
            Label {
                Text("Works offline - no internet required")
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
                Text("AI processing is not available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Requirements:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text("• iOS 26.0 or later")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Text("• Apple Intelligence enabled")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Text("• Compatible device")
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
