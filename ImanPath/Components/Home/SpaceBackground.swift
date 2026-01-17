//
//  SpaceBackground.swift
//  ImanPath
//

import SwiftUI

struct SpaceBackground: View {
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            // Subtle green glow top-left
            Circle()
                .fill(Color(hex: "74B886").opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: -100, y: -200)

            // Subtle blue glow bottom-right
            Circle()
                .fill(Color.blue.opacity(0.05))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: 150, y: 300)
        }
    }
}

#Preview {
    SpaceBackground()
}
