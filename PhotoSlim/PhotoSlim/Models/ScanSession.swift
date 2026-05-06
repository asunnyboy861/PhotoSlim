import Foundation
import SwiftData

@Model
final class ScanSession {
    var id: String
    var startedAt: Date
    var completedAt: Date?
    var totalPhotos: Int
    var duplicateGroups: Int
    var blurryPhotos: Int
    var screenshots: Int
    var totalReclaimableSpace: Int64
    var isCompleted: Bool

    var records: [PhotoRecord] = []

    init(
        id: String = UUID().uuidString,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        totalPhotos: Int = 0,
        duplicateGroups: Int = 0,
        blurryPhotos: Int = 0,
        screenshots: Int = 0,
        totalReclaimableSpace: Int64 = 0,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.totalPhotos = totalPhotos
        self.duplicateGroups = duplicateGroups
        self.blurryPhotos = blurryPhotos
        self.screenshots = screenshots
        self.totalReclaimableSpace = totalReclaimableSpace
        self.isCompleted = isCompleted
    }
}
