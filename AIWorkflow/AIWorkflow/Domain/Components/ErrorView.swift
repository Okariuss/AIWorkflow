//
//  ErrorView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 21.11.2025.
//

import SwiftUI

struct ErrorView: View {
    
    let error: String
    let retryAction: (() -> Void)?
    
    init(error: String, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            Text(L10N.Common.error)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction {
                Button(action: retryAction) {
                    Label(L10N.Common.retry, systemImage: "arrow.clockwise")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}
