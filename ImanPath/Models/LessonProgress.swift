//
//  LessonProgress.swift
//  ImanPath
//
//  SwiftData model for tracking lesson completion
//

import Foundation
import SwiftData

@Model
final class LessonProgress {
    var lessonDay: Int
    var completedAt: Date
    var reflectionResponse: String?

    init(lessonDay: Int, completedAt: Date = Date(), reflectionResponse: String? = nil) {
        self.lessonDay = lessonDay
        self.completedAt = completedAt
        self.reflectionResponse = reflectionResponse
    }
}
