//
//  AppTheme.swift
//  ImanPath
//

import SwiftUI

// MARK: - Colors

extension Color {
    // Background
    static let appBackground = Color(hex: "0A1628")
    static let appBackgroundSecondary = Color(hex: "111D2E")
    static let cardBackground = Color(hex: "1A2737")

    // Accent
    static let appGold = Color(hex: "D4AF37")
    static let appGoldLight = Color(hex: "E8C76B")

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "A0AEC0")
    static let textMuted = Color(hex: "718096")

    // States
    static let success = Color(hex: "48BB78")
    static let warning = Color(hex: "ED8936")
    static let danger = Color(hex: "FC8181")

    // Helpers
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography

extension Font {
    // Display
    static let streakNumber = Font.system(size: 72, weight: .bold, design: .rounded)
    static let streakLabel = Font.system(size: 16, weight: .medium)

    // Headings
    static let heading1 = Font.system(size: 24, weight: .bold)
    static let heading2 = Font.system(size: 20, weight: .semibold)
    static let heading3 = Font.system(size: 17, weight: .semibold)

    // Body
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyRegular = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)

    // Accent
    static let caption = Font.system(size: 12, weight: .medium)
    static let button = Font.system(size: 17, weight: .semibold)
}

// MARK: - Spacing

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xl: CGFloat = 24
}
