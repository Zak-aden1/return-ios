//
//  SectionDivider.swift
//  ImanPath
//

import SwiftUI

struct SectionDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            // Left line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "334155").opacity(0), Color(hex: "334155")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)

            // Center dot
            Circle()
                .fill(Color(hex: "334155"))
                .frame(width: 4, height: 4)

            // Right line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "334155"), Color(hex: "334155").opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Section 1")
            .foregroundColor(.white)

        SectionDivider()

        Text("Section 2")
            .foregroundColor(.white)
    }
    .padding()
    .background(Color(hex: "0A1628"))
}
