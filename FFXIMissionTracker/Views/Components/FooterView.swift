//
//  FooterView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack(spacing: 6) {
            Divider()

            VStack(spacing: 4) {
                Text("Vana'diel Progress Tracker v1.0")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Text("Data from")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Link("FFXIclopedia", destination: URL(string: "https://ffxiclopedia.fandom.com")!)
                        .font(.caption2)
                        .foregroundStyle(.blue)

                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("Not affiliated with Square Enix")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.secondary.opacity(0.08),
                    Color.secondary.opacity(0.12)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    FooterView()
}
