import Foundation
import SwiftData

@Model
final class UserPreferences {
    var similarityThreshold: Float
    var sharpnessThreshold: Float
    var autoSelectBest: Bool
    var protectFavorites: Bool
    var scanScope: String
    var dailyDeleteCount: Int
    var lastResetDate: Date
    var isPro: Bool
    var hasCompletedOnboarding: Bool

    init(
        similarityThreshold: Float = 0.85,
        sharpnessThreshold: Float = 100,
        autoSelectBest: Bool = true,
        protectFavorites: Bool = true,
        scanScope: String = "all",
        dailyDeleteCount: Int = 0,
        lastResetDate: Date = Date(),
        isPro: Bool = false,
        hasCompletedOnboarding: Bool = false
    ) {
        self.similarityThreshold = similarityThreshold
        self.sharpnessThreshold = sharpnessThreshold
        self.autoSelectBest = autoSelectBest
        self.protectFavorites = protectFavorites
        self.scanScope = scanScope
        self.dailyDeleteCount = dailyDeleteCount
        self.lastResetDate = lastResetDate
        self.isPro = isPro
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    var canDeleteToday: Bool {
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            return true
        }
        return dailyDeleteCount < 5 || isPro
    }

    var remainingDeletesToday: Int {
        if isPro { return Int.max }
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            return 5
        }
        return max(0, 5 - dailyDeleteCount)
    }
}
