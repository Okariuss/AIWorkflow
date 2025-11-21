//
//  LoadingView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 21.11.2025.
//

import SwiftUI

struct LoadingView: View {
    
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}
