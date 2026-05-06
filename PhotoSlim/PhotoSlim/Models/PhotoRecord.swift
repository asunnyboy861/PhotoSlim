import Foundation
import SwiftData

@Model
final class PhotoRecord {
    var assetId: String
    var contentHash: String?
    var category: PhotoCategory
    var sharpnessScore: Float
    var isDuplicate: Bool
    var duplicateGroupId: String?
    var faceCount: Int
    var fileSize: Int64
    var createdAt: Date
    var scannedAt: Date

    var scanSession: ScanSession?

    init(
        assetId: String,
        contentHash: String? = nil,
        category: PhotoCategory = .normal,
        sharpnessScore: Float = 0,
        isDuplicate: Bool = false,
        duplicateGroupId: String? = nil,
        faceCount: Int = 0,
        fileSize: Int64 = 0,
        createdAt: Date = Date(),
        scannedAt: Date = Date()
    ) {
        self.assetId = assetId
        self.contentHash = contentHash
        self.category = category
        self.sharpnessScore = sharpnessScore
        self.isDuplicate = isDuplicate
        self.duplicateGroupId = duplicateGroupId
        self.faceCount = faceCount
        self.fileSize = fileSize
        self.createdAt = createdAt
        self.scannedAt = scannedAt
    }
}
