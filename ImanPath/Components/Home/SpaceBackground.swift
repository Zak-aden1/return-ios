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

            // Star field (similar to tutorial screen)
            HomeStarFieldView()

            GeometryReader { geometry in
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
        .ignoresSafeArea()
    }
}

// MARK: - Star Field (matches TutorialView style)
private struct HomeStarFieldView: View {
    // Pre-computed star positions to avoid re-randomizing on re-render
    private let stars: [StarData] = {
        var result: [StarData] = []
        // Use deterministic positions for home screen
        let positions: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = [
            // Upper area stars
            (0.08, 0.05, 1.5, 0.5),
            (0.22, 0.03, 1.0, 0.35),
            (0.35, 0.08, 2.0, 0.45),
            (0.52, 0.02, 1.0, 0.3),
            (0.68, 0.06, 1.5, 0.5),
            (0.85, 0.04, 1.0, 0.4),
            (0.95, 0.09, 1.5, 0.35),
            (0.15, 0.12, 1.0, 0.4),
            (0.42, 0.14, 1.5, 0.5),
            (0.78, 0.11, 2.0, 0.45),
            // Mid-upper area
            (0.05, 0.18, 1.0, 0.3),
            (0.28, 0.22, 1.5, 0.4),
            (0.55, 0.19, 1.0, 0.35),
            (0.72, 0.24, 1.5, 0.45),
            (0.92, 0.20, 1.0, 0.3),
            // Mid area
            (0.12, 0.32, 1.0, 0.25),
            (0.38, 0.28, 1.5, 0.35),
            (0.62, 0.35, 1.0, 0.3),
            (0.88, 0.30, 1.5, 0.4),
            // Lower-mid area (fewer, dimmer)
            (0.18, 0.45, 1.0, 0.25),
            (0.48, 0.42, 1.0, 0.2),
            (0.75, 0.48, 1.5, 0.3),
            (0.95, 0.44, 1.0, 0.25),
            // Scattered lower (very subtle)
            (0.08, 0.58, 1.0, 0.2),
            (0.32, 0.55, 1.0, 0.2),
            (0.65, 0.60, 1.0, 0.2),
            (0.85, 0.56, 1.0, 0.25),
        ]

        for pos in positions {
            result.append(StarData(
                xPercent: pos.x,
                yPercent: pos.y,
                size: pos.size,
                opacity: pos.opacity
            ))
        }
        return result
    }()

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(stars[i].opacity))
                    .frame(width: stars[i].size, height: stars[i].size)
                    .position(
                        x: geo.size.width * stars[i].xPercent,
                        y: geo.size.height * stars[i].yPercent
                    )
            }
        }
        .ignoresSafeArea()
    }
}

private struct StarData {
    let xPercent: CGFloat
    let yPercent: CGFloat
    let size: CGFloat
    let opacity: Double
}

#Preview {
    SpaceBackground()
}
