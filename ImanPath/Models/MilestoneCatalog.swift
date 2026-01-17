//
//  MilestoneCatalog.swift
//  ImanPath
//

import SwiftUI

struct MilestoneDefinition: Identifiable {
    let day: Int
    let title: String
    let islamicName: String
    let meaning: String
    let verse: String?
    let verseReference: String?
    let icon: String
    let colors: [Color]

    var id: Int { day }
}

enum MilestoneCatalog {
    static let definitions: [MilestoneDefinition] = [
        MilestoneDefinition(
            day: 1,
            title: "First Step",
            islamicName: "Tawbah",
            meaning: "Repentance - Turning back to Allah with sincere intention. The first step on the path to purification.",
            verse: "Indeed, Allah loves those who are constantly repentant.",
            verseReference: "Quran 2:222",
            icon: "leaf.fill",
            colors: [Color(hex: "74B886"), Color(hex: "5A9A6E")]
        ),
        MilestoneDefinition(
            day: 3,
            title: "Reborn",
            islamicName: "Tajdeed",
            meaning: "Renewal - Refreshing your commitment and faith. A new beginning takes root.",
            verse: nil,
            verseReference: nil,
            icon: "sunrise.fill",
            colors: [Color(hex: "F5D485"), Color(hex: "E8B86D")]
        ),
        MilestoneDefinition(
            day: 7,
            title: "First Week",
            islamicName: "Sabr",
            meaning: "Patience - Steadfastness through difficulty. You've proven you can endure.",
            verse: "Indeed, Allah is with the patient.",
            verseReference: "Quran 2:153",
            icon: "shield.fill",
            colors: [Color(hex: "60A5FA"), Color(hex: "3B82F6")]
        ),
        MilestoneDefinition(
            day: 14,
            title: "Two Weeks",
            islamicName: "Istiqamah",
            meaning: "Steadfastness - Consistency on the straight path. Your habits are forming.",
            verse: "So remain on a right course as you have been commanded.",
            verseReference: "Quran 11:112",
            icon: "arrow.up.circle.fill",
            colors: [Color(hex: "8B5CF6"), Color(hex: "7C3AED")]
        ),
        MilestoneDefinition(
            day: 30,
            title: "One Month",
            islamicName: "Mujahadah",
            meaning: "Striving - The inner struggle against the self. A full month of victory.",
            verse: "And those who strive for Us, We will surely guide them to Our ways.",
            verseReference: "Quran 29:69",
            icon: "flame.fill",
            colors: [Color(hex: "F97316"), Color(hex: "EA580C")]
        ),
        MilestoneDefinition(
            day: 50,
            title: "Fifty Days",
            islamicName: "Thiqah",
            meaning: "Confidence - Growing trust in yourself and Allah's plan. You're building strength.",
            verse: nil,
            verseReference: nil,
            icon: "hand.raised.fill",
            colors: [Color(hex: "EC4899"), Color(hex: "DB2777")]
        ),
        MilestoneDefinition(
            day: 60,
            title: "Two Months",
            islamicName: "Taqwa",
            meaning: "God-consciousness - Awareness of Allah in all actions. Your heart is awakening.",
            verse: "And whoever fears Allah, He will make for him a way out.",
            verseReference: "Quran 65:2",
            icon: "eye.fill",
            colors: [Color(hex: "5B9A9A"), Color(hex: "4A8585")]
        ),
        MilestoneDefinition(
            day: 75,
            title: "Seventy-Five Days",
            islamicName: "Tawakkul",
            meaning: "Reliance - Complete trust and dependence on Allah. You've surrendered control.",
            verse: "Whoever relies upon Allah, then He is sufficient for him.",
            verseReference: "Quran 65:3",
            icon: "hands.sparkles.fill",
            colors: [Color(hex: "A78BDA"), Color(hex: "8B5CF6")]
        ),
        MilestoneDefinition(
            day: 90,
            title: "Three Months",
            islamicName: "Ihsan",
            meaning: "Excellence - Worshipping Allah as if you see Him. Mastery is within reach.",
            verse: "Indeed, Allah is with those who fear Him and those who do good.",
            verseReference: "Quran 16:128",
            icon: "star.fill",
            colors: [Color(hex: "FBBF24"), Color(hex: "F59E0B")]
        ),
        MilestoneDefinition(
            day: 120,
            title: "Four Months",
            islamicName: "Quwwah",
            meaning: "Strength - Inner power developed through perseverance. You are transformed.",
            verse: "Allah does not burden a soul beyond that it can bear.",
            verseReference: "Quran 2:286",
            icon: "bolt.fill",
            colors: [Color(hex: "EF4444"), Color(hex: "DC2626")]
        ),
        MilestoneDefinition(
            day: 150,
            title: "Five Months",
            islamicName: "Shukr",
            meaning: "Gratitude - Thankfulness for Allah's guidance and mercy. Blessings multiply.",
            verse: "If you are grateful, I will surely increase you.",
            verseReference: "Quran 14:7",
            icon: "heart.fill",
            colors: [Color(hex: "F472B6"), Color(hex: "EC4899")]
        ),
        MilestoneDefinition(
            day: 270,
            title: "Nine Months",
            islamicName: "Noor",
            meaning: "Light - The radiance of a purified heart. You shine with inner peace.",
            verse: "Allah is the Light of the heavens and the earth.",
            verseReference: "Quran 24:35",
            icon: "sun.max.fill",
            colors: [Color(hex: "FDE047"), Color(hex: "FACC15")]
        ),
        MilestoneDefinition(
            day: 365,
            title: "One Year",
            islamicName: "Falah",
            meaning: "Success - True triumph through spiritual victory. A complete transformation.",
            verse: "Indeed, the patient will be given their reward without account.",
            verseReference: "Quran 39:10",
            icon: "crown.fill",
            colors: [Color(hex: "E8B86D"), Color(hex: "D4A056")]
        )
    ]

    static var days: [Int] {
        definitions.map { $0.day }
    }

    static func definition(for day: Int) -> MilestoneDefinition? {
        definitions.first { $0.day == day }
    }

    static func next(after day: Int) -> MilestoneDefinition? {
        definitions.first { $0.day > day }
    }

    static let majorDays: [Int] = [7, 30, 60, 90]
    static let commitmentDays: [Int] = [30, 60, 90]
}
