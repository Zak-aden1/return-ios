//
//  DailyVerses.swift
//  ImanPath
//
//  30 rotating verses for daily inspiration
//

import Foundation

struct DailyVerse {
    let text: String
    let reference: String
}

enum DailyVerses {
    static let verses: [DailyVerse] = [
        DailyVerse(text: "Verily, with hardship comes ease.", reference: "Quran 94:6"),
        DailyVerse(text: "Allah does not burden a soul beyond what it can bear.", reference: "Quran 2:286"),
        DailyVerse(text: "Despair not of the mercy of Allah.", reference: "Quran 39:53"),
        DailyVerse(text: "And He found you lost and guided you.", reference: "Quran 93:7"),
        DailyVerse(text: "Indeed, Allah loves those who repent.", reference: "Quran 2:222"),
        DailyVerse(text: "So remember Me; I will remember you.", reference: "Quran 2:152"),
        DailyVerse(text: "Call upon Me; I will respond to you.", reference: "Quran 40:60"),
        DailyVerse(text: "Indeed, my Lord is near and responsive.", reference: "Quran 11:61"),
        DailyVerse(text: "Whoever puts their trust in Allah, He will be enough for them.", reference: "Quran 65:3"),
        DailyVerse(text: "He is with you wherever you are.", reference: "Quran 57:4"),
        DailyVerse(text: "We are closer to him than his jugular vein.", reference: "Quran 50:16"),
        DailyVerse(text: "Indeed, prayer prohibits immorality and wrongdoing.", reference: "Quran 29:45"),
        DailyVerse(text: "Seek help through patience and prayer.", reference: "Quran 2:45"),
        DailyVerse(text: "My mercy encompasses all things.", reference: "Quran 7:156"),
        DailyVerse(text: "Allah wants to lighten your burden.", reference: "Quran 4:28"),
        DailyVerse(text: "Do not lose hope, nor be sad.", reference: "Quran 3:139"),
        DailyVerse(text: "In the remembrance of Allah do hearts find rest.", reference: "Quran 13:28"),
        DailyVerse(text: "Be patient. Indeed, the promise of Allah is truth.", reference: "Quran 30:60"),
        DailyVerse(text: "The patient will be given their reward without measure.", reference: "Quran 39:10"),
        DailyVerse(text: "Allah is with those who patiently persevere.", reference: "Quran 2:153"),
        DailyVerse(text: "Whoever fears Allah, He will make a way out for him.", reference: "Quran 65:2"),
        DailyVerse(text: "Allah is Subtle with His servants.", reference: "Quran 42:19"),
        DailyVerse(text: "Allah is the Light of the heavens and the earth.", reference: "Quran 24:35"),
        DailyVerse(text: "Your Lord has not forsaken you, nor has He become displeased.", reference: "Quran 93:3"),
        DailyVerse(text: "Indeed, Allah is ever Accepting of repentance.", reference: "Quran 4:16"),
        DailyVerse(text: "Is not Allah sufficient for His servant?", reference: "Quran 39:36"),
        DailyVerse(text: "And Allah is full of kindness to His servants.", reference: "Quran 2:207"),
        DailyVerse(text: "Take one step towards Allah, He takes ten towards you.", reference: "Hadith"),
        DailyVerse(text: "The best of sinners are those who repent.", reference: "Hadith"),
        DailyVerse(text: "Allah is more merciful to His servants than a mother to her child.", reference: "Hadith"),
    ]

    /// Returns today's verse based on day of month (1-30/31 cycles through 30 verses)
    static var today: DailyVerse {
        let day = Calendar.current.component(.day, from: Date())
        let index = (day - 1) % verses.count
        return verses[index]
    }
}
