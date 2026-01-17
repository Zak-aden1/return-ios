//
//  RadarChartView.swift
//  ImanPath
//

import SwiftUI

struct RadarDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double // 0-100
}

struct RadarChartView: View {
    let data: [RadarDataPoint]
    let accentColor: Color

    @State private var animationProgress: CGFloat = 0

    private var overallScore: Int {
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.value }
        return Int(total / Double(data.count))
    }

    var body: some View {
        VStack(spacing: 16) {
            // Chart
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = size / 2 - 40

                ZStack {
                    // Grid lines (concentric pentagons)
                    ForEach([0.2, 0.4, 0.6, 0.8, 1.0], id: \.self) { scale in
                        RadarGridShape(sides: data.count, scale: scale)
                            .stroke(Color(hex: "334155").opacity(scale == 1.0 ? 0.6 : 0.3), lineWidth: 1)
                            .frame(width: radius * 2, height: radius * 2)
                            .position(center)
                    }

                    // Axis lines from center to each vertex
                    ForEach(0..<data.count, id: \.self) { index in
                        let angle = angleFor(index: index, total: data.count) - .pi / 2
                        let endPoint = CGPoint(
                            x: center.x + cos(angle) * radius,
                            y: center.y + sin(angle) * radius
                        )

                        Path { path in
                            path.move(to: center)
                            path.addLine(to: endPoint)
                        }
                        .stroke(Color(hex: "334155").opacity(0.3), lineWidth: 1)
                    }

                    // Data fill
                    RadarDataShape(data: data.map { $0.value / 100 }, progress: animationProgress)
                        .fill(
                            RadialGradient(
                                colors: [accentColor.opacity(0.6), accentColor.opacity(0.2)],
                                center: .center,
                                startRadius: 0,
                                endRadius: radius
                            )
                        )
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)

                    // Data stroke
                    RadarDataShape(data: data.map { $0.value / 100 }, progress: animationProgress)
                        .stroke(accentColor, lineWidth: 2)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                        .shadow(color: accentColor.opacity(0.5), radius: 8)

                    // Data points
                    ForEach(0..<data.count, id: \.self) { index in
                        let value = data[index].value / 100 * animationProgress
                        let angle = angleFor(index: index, total: data.count) - .pi / 2
                        let pointRadius = radius * value
                        let point = CGPoint(
                            x: center.x + cos(angle) * pointRadius,
                            y: center.y + sin(angle) * pointRadius
                        )

                        Circle()
                            .fill(accentColor)
                            .frame(width: 8, height: 8)
                            .shadow(color: accentColor.opacity(0.8), radius: 4)
                            .position(point)
                    }

                    // Labels
                    ForEach(0..<data.count, id: \.self) { index in
                        let angle = angleFor(index: index, total: data.count) - .pi / 2
                        let labelRadius = radius + 28
                        let point = CGPoint(
                            x: center.x + cos(angle) * labelRadius,
                            y: center.y + sin(angle) * labelRadius
                        )

                        Text(data[index].label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "94A3B8"))
                            .position(point)
                    }

                    // Center score
                    VStack(spacing: 2) {
                        Text("\(Int(Double(overallScore) * animationProgress))%")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Overall")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                    .position(center)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }

            // Legend
            HStack(spacing: 6) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 8, height: 8)
                Text("Last 7 Days")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "64748B"))
            }
        }
    }

    private func angleFor(index: Int, total: Int) -> CGFloat {
        CGFloat(index) * (2 * .pi / CGFloat(total))
    }
}

// MARK: - Shapes

struct RadarGridShape: Shape {
    let sides: Int
    let scale: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * scale

        for i in 0..<sides {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(sides)) - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()

        return path
    }
}

struct RadarDataShape: Shape {
    let data: [Double]
    var progress: CGFloat = 1.0

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2

        guard !data.isEmpty else { return path }

        for i in 0..<data.count {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(data.count)) - .pi / 2
            let radius = maxRadius * data[i] * progress
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()

        return path
    }
}

#Preview {
    RadarChartView(
        data: [
            RadarDataPoint(label: "Mood", value: 75),
            RadarDataPoint(label: "Energy", value: 60),
            RadarDataPoint(label: "Self Control", value: 85),
            RadarDataPoint(label: "Faith", value: 90),
            RadarDataPoint(label: "Confidence", value: 55)
        ],
        accentColor: Color(hex: "74B886")
    )
    .frame(height: 280)
    .padding()
    .background(Color(hex: "0A1628"))
}
