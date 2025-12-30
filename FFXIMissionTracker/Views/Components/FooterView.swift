//
//  FooterView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack(spacing: 4) {
            Divider()
            Text("Mission Tracker v1.0")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))
    }
}

#Preview {
    FooterView()
}
