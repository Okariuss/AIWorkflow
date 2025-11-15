//
//  StatItemView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import SwiftUI

struct StatItemView: View {
    
    // MARK: - Properties
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
